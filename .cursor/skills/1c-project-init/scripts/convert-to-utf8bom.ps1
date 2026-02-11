param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

# Read file content (try different encodings)
try {
    $content = Get-Content $FilePath -Raw -Encoding UTF8
} catch {
    Write-Host "UTF-8 failed, trying default encoding..." -ForegroundColor Yellow
    $content = Get-Content $FilePath -Raw
}

# Prepare UTF-8 BOM encoding
$utf8bom = New-Object System.Text.UTF8Encoding($true)

# Write back with UTF-8 BOM
[System.IO.File]::WriteAllText($FilePath, $content, $utf8bom)

# Verify BOM
$bytes = [System.IO.File]::ReadAllBytes($FilePath)
$bom = "{0:X2} {1:X2} {2:X2}" -f $bytes[0], $bytes[1], $bytes[2]

if ($bom -eq "EF BB BF") {
    Write-Host "Successfully converted to UTF-8 BOM: $FilePath" -ForegroundColor Green
    Write-Host "BOM: $bom" -ForegroundColor Green
} else {
    Write-Error "BOM verification failed: $bom (expected EF BB BF)"
    exit 1
}
