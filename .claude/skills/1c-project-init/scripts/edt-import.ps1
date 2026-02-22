# edt-import.ps1 — Add 1C project to EDT workspace on CT107
# Modes: project (existing EDT), xml (from 1C XML src), dt (from .dt dump)
#
# Usage:
#   project: .\edt-import.ps1 -Mode project -Source /opt/edt-workspace/MyProject
#   xml:     .\edt-import.ps1 -Mode xml -Source /mnt/data/deploy/MyProject/src -ProjectName MyProject
#   dt:      .\edt-import.ps1 -Mode dt -Source /mnt/data/MyDB.dt -ProjectName MyProject -WithExtensions

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("project","xml","dt")]
    [string]$Mode,

    [Parameter(Mandatory=$true)]
    [string]$Source,            # EDT project path | xml src path on CT107 | .dt path (local or CT107)

    [string]$ProjectName,       # EDT project name (Latin, required for xml/dt modes)

    [ValidateSet("8.3.24","8.3.25")]
    [string]$PlatformVersion = "8.3.24",

    [ValidateSet("24","25")]
    [string]$ServerVersion = "24",

    [ValidateSet("configuration","extension")]
    [string]$ProjectType = "configuration",

    [string]$BaseProjectName = "",  # for extension type: parent config project name in EDT

    [switch]$WithExtensions,        # dt mode: also import all extensions from IB

    [string]$CT107 = "root@YOUR_EDT_SERVER"
)

$EDT_WORKSPACE = "/opt/edt-workspace"
$EDT_CLI      = "/opt/edt-app/data/1cedtcli"
$CONTAINER    = "onec-server-$ServerVersion"
$DB_HOST      = "onec-postgres"
$DB_USER      = "onec"
$DB_PWD       = "YOUR_ONEC_PASSWORD"
$DEPLOY_DIR   = "/mnt/data/deploy"

# --- helpers ---

function SSH([string]$cmd) {
    ssh $CT107 $cmd
    return $LASTEXITCODE
}

function SSH-Out([string]$cmd) {
    return ssh $CT107 $cmd
}

function Find-Ibcmd {
    $path = SSH-Out "find /opt/1cv8 -name ibcmd -path '*$PlatformVersion*' 2>/dev/null | head -1"
    if (-not $path) {
        $path = SSH-Out "find /opt/1cv8 -name ibcmd 2>/dev/null | grep $PlatformVersion | head -1"
    }
    if (-not $path) { throw "ibcmd not found for platform $PlatformVersion in container $CONTAINER" }
    return $path.Trim()
}

function Docker-Ibcmd([string]$args) {
    $ibcmd = Find-Ibcmd
    $connArgs = "--dbms=PostgreSQL --db-server=$DB_HOST --db-user=$DB_USER --db-pwd=$DB_PWD"
    SSH "docker exec $CONTAINER $ibcmd $args $connArgs"
    return $LASTEXITCODE
}

function Stop-EDT {
    Write-Host "Stopping EDT..."
    SSH "systemctl stop edt"
    Start-Sleep 3
    SSH "pkill -9 -f '1cedt' 2>/dev/null || true"
    Start-Sleep 1
    $javaCount = SSH-Out "ps aux | grep java | grep -v grep | wc -l"
    if ($javaCount.Trim() -ne "0") {
        Write-Warning "EDT java processes still running after stop. Waiting..."
        Start-Sleep 5
    }
}

function Start-EDT {
    Write-Host "Starting EDT..."
    SSH "systemctl start edt"
    Write-Host "EDT started. Allow 2-3 min for indexing."
}

function Ensure-PMF([string]$projectPath, [string]$version) {
    $pmfPath = "$projectPath/DT-INF/PROJECT.PMF"
    $exists = SSH-Out "test -f '$pmfPath' && echo yes || echo no"
    if ($exists.Trim() -ne "yes") {
        Write-Host "Creating DT-INF/PROJECT.PMF..."
        SSH "mkdir -p '$projectPath/DT-INF' && printf 'Manifest-Version: 1.0\nRuntime-Version: $version\n' > '$pmfPath'"
    }
}

function Import-EDTProject([string]$projectPath) {
    Write-Host "Importing EDT project: $projectPath"
    $rc = SSH "DISPLAY=:99 $EDT_CLI -data $EDT_WORKSPACE -timeout 600 -command import --project '$projectPath' 2>&1"
    if ($rc -ne 0) { throw "1cedtcli import failed (exit $rc)" }
}

function Import-EDTFromXml([string]$srcPath, [string]$name, [string]$version, [string]$baseName) {
    Write-Host "Importing from XML: $srcPath -> $name"
    $baseArg = if ($baseName) { "--base-project-name '$baseName'" } else { "" }
    $rc = SSH "DISPLAY=:99 $EDT_CLI -data $EDT_WORKSPACE -timeout 900 -command import --version '$version' $baseArg --configuration-files '$srcPath' --project-name '$name' --build false 2>&1"
    if ($rc -ne 0) { throw "1cedtcli import --configuration-files failed (exit $rc)" }
}

function Validate-LatinName([string]$name) {
    if ($name -match '[^\x00-\x7F]') {
        throw "Project name '$name' contains non-Latin characters. EDT requires Latin-only directory names."
    }
}

# --- mode: project ---

function Run-ProjectMode {
    if (-not $Source) { throw "-Source required: path to existing EDT project on CT107" }

    $name = Split-Path $Source -Leaf
    Validate-LatinName $name

    $exists = SSH-Out "test -d '$Source/.git' -o -f '$Source/.project' && echo yes || echo no"
    if ($exists.Trim() -ne "yes") { throw "No .project file found at: $Source" }

    Ensure-PMF $Source $PlatformVersion

    Stop-EDT
    Import-EDTProject $Source
    Start-EDT

    Write-Host "Done. Project '$name' imported."
}

# --- mode: xml ---

function Run-XmlMode {
    if (-not $ProjectName) { throw "-ProjectName required for xml mode" }
    Validate-LatinName $ProjectName

    $projectPath = "$EDT_WORKSPACE/$ProjectName"
    $srcPath     = $Source   # must be path on CT107

    Ensure-PMF $projectPath $PlatformVersion

    Stop-EDT
    $baseArg = if ($BaseProjectName) { $BaseProjectName } else { "" }
    Import-EDTFromXml $srcPath $ProjectName $PlatformVersion $baseArg
    Start-EDT

    Write-Host "Done. Project '$ProjectName' imported from XML."
}

# --- mode: dt ---

function Run-DtMode {
    if (-not $ProjectName) { throw "-ProjectName required for dt mode" }
    Validate-LatinName $ProjectName

    # 1. Copy .dt to CT107 if local path
    $dtPathOnCT107 = $Source
    if ($Source -match '^[A-Z]:\\' -or $Source -match '^\.') {
        Write-Host "Copying .dt to CT107..."
        $fileName = Split-Path $Source -Leaf
        scp $Source "${CT107}:/mnt/data/$fileName"
        if ($LASTEXITCODE -ne 0) { throw "scp failed" }
        $dtPathOnCT107 = "/mnt/data/$fileName"
    }

    # 2. DB name (lowercase, no special chars)
    $dbName = $ProjectName.ToLower() -replace '[^a-z0-9_]', '_'
    Write-Host "DB name: $dbName"

    # 3. Find ibcmd
    $ibcmd = SSH-Out "docker exec $CONTAINER find /opt/1cv8 -name ibcmd 2>/dev/null | grep '$PlatformVersion' | head -1"
    $ibcmd = $ibcmd.Trim()
    if (-not $ibcmd) { throw "ibcmd not found in $CONTAINER for $PlatformVersion" }
    $conn = "--dbms=PostgreSQL --db-server=$DB_HOST --db-user=$DB_USER --db-pwd=$DB_PWD --db-name=$dbName"

    # 4. Restore .dt to new infobase
    Write-Host "Restoring IB from .dt..."
    $rc = SSH "docker exec $CONTAINER $ibcmd infobase create $conn --create-database --restore=$dtPathOnCT107 2>&1"
    if ($rc -ne 0) { throw "ibcmd infobase create --restore failed" }

    # 5. Export main config to XML
    $srcPath = "$DEPLOY_DIR/$ProjectName/src"
    Write-Host "Exporting config to $srcPath..."
    SSH "mkdir -p '$srcPath'"
    $rc = SSH "docker exec $CONTAINER $ibcmd config export $conn --dir=$srcPath 2>&1"
    if ($rc -ne 0) { throw "ibcmd config export failed" }

    # 6. Import main config into EDT
    Stop-EDT
    Import-EDTFromXml $srcPath $ProjectName $PlatformVersion ""

    # 7. Extensions
    if ($WithExtensions) {
        Write-Host "Listing extensions..."
        $extList = SSH-Out "docker exec $CONTAINER $ibcmd extension list $conn 2>&1"
        $extNames = $extList -split "`n" |
            Where-Object { $_ -match '^\s*\w' -and $_ -notmatch '1C:Enterprise|ibcmd|Инструменты' } |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -ne "" }

        Write-Host "Found extensions: $($extNames -join ', ')"

        foreach ($ext in $extNames) {
            $extLatin = $ext -replace '[^\x00-\x7F]', '' -replace '\s+', '_'
            if (-not $extLatin) { $extLatin = "Ext_$([System.Guid]::NewGuid().ToString('N').Substring(0,6))" }

            $extSrc = "$DEPLOY_DIR/$extLatin/src"
            Write-Host "Exporting extension '$ext' -> $extSrc..."
            SSH "mkdir -p '$extSrc'"
            $rc = SSH "docker exec $CONTAINER $ibcmd config export $conn --extension='$ext' --dir=$extSrc 2>&1"
            if ($rc -ne 0) {
                Write-Warning "Failed to export extension '$ext', skipping."
                continue
            }

            Import-EDTFromXml $extSrc $extLatin $PlatformVersion $ProjectName
            Write-Host "Extension '$ext' imported as '$extLatin'."
        }
    }

    Start-EDT
    Write-Host "Done. Project '$ProjectName' imported from .dt."
    if ($WithExtensions) { Write-Host "Extensions imported. Check EDT workspace with edt-mcp list_projects." }
}

# --- main ---

try {
    switch ($Mode) {
        "project" { Run-ProjectMode }
        "xml"     { Run-XmlMode }
        "dt"      { Run-DtMode }
    }
} catch {
    Write-Error "edt-import failed: $_"
    exit 1
}
