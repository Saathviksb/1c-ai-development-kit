# check-prerequisites.ps1
# Проверка предусловий для инициализации проекта 1С

param(
    [string]$Server,
    [string]$Database,
    [string]$Username,
    [string]$Password = "",
    [string]$OneCPath
)

$checks = @{
    PowerShell = $false
    Git = $false
    OneC = $false
    Database = $false
}

Write-Host ""
Write-Host "=== Проверка предусловий ===" -ForegroundColor Cyan
Write-Host ""

# 1. PowerShell
Write-Host "[INFO] Проверка PowerShell..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5 -and $psVersion.Minor -ge 1) {
    Write-Host "[OK] PowerShell $($psVersion.Major).$($psVersion.Minor)" -ForegroundColor Green
    $checks.PowerShell = $true
} else {
    Write-Host "[FAIL] PowerShell $($psVersion.Major).$($psVersion.Minor) (требуется >= 5.1)" -ForegroundColor Red
}

# 2. Git
Write-Host "[INFO] Проверка Git..." -ForegroundColor Cyan
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] $gitVersion" -ForegroundColor Green
        $checks.Git = $true
    } else {
        Write-Host "[FAIL] Git не найден" -ForegroundColor Red
    }
} catch {
    Write-Host "[FAIL] Git не найден" -ForegroundColor Red
}

# 3. 1С:Предприятие
Write-Host "[INFO] Проверка 1С:Предприятие..." -ForegroundColor Cyan

# Если путь указан явно, используем его
if ($OneCPath -and (Test-Path $OneCPath)) {
    $onecExe = $OneCPath
} else {
    # Ищем автоматически
    $possiblePaths = @()
    $programFiles = @(${env:ProgramFiles}, ${env:ProgramFiles(x86)})
    foreach ($pf in $programFiles) {
        if ($pf) {
            $onecDir = Join-Path $pf "1cv8"
            if (Test-Path $onecDir) {
                Get-ChildItem -Path $onecDir -Directory | ForEach-Object {
                    $exePath = Join-Path $_.FullName "bin\1cv8.exe"
                    if (Test-Path $exePath) {
                        $possiblePaths += $exePath
                    }
                }
            }
        }
    }
    
    if ($possiblePaths.Count -gt 0) {
        $onecExe = $possiblePaths | Sort-Object -Descending | Select-Object -First 1
    } else {
        $onecExe = $null
    }
}

if ($onecExe) {
    $versionInfo = (Get-Item $onecExe).VersionInfo
    $version = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart).$($versionInfo.FilePrivatePart)"
    
    Write-Host "[OK] 1С:Предприятие $version" -ForegroundColor Green
    Write-Host "     Путь: $onecExe" -ForegroundColor Gray
    $checks.OneC = $true
    $script:OneCExePath = $onecExe
} else {
    Write-Host "[FAIL] 1С:Предприятие не найдено" -ForegroundColor Red
}

# 4. База (если параметры указаны)
if ($Server -and $Database -and $checks.OneC) {
    Write-Host "[INFO] Проверка базы (через bat-скрипт)..." -ForegroundColor Cyan
    Write-Host "     Сервер: $Server" -ForegroundColor Gray
    Write-Host "     База: $Database" -ForegroundColor Gray
    Write-Host "     Пользователь: $Username" -ForegroundColor Gray
    
    # Создаём временный .bat для проверки
    $tempBat = Join-Path $env:TEMP "check-1c-$(Get-Random).bat"
    $tempDir = Join-Path $env:TEMP "1c_check_$(Get-Random)"
    $tempLog = Join-Path $env:TEMP "1c_check_$(Get-Random).log"
    
    $batContent = @"
@echo off
chcp 65001 >nul
set "ONEC_PATH=$($script:OneCExePath)"
set "ONEC_SERVER=$Server"
set "ONEC_BASE=$Database"
set "ONEC_USER=$Username"
set "ONEC_PASSWORD=$Password"

set "IB_PARAMS=/S "%ONEC_SERVER%\%ONEC_BASE%""
set "AUTH_PARAMS="
if not "%ONEC_USER%"=="" set AUTH_PARAMS=/N"%ONEC_USER%"
if not "%ONEC_PASSWORD%"=="" set AUTH_PARAMS=%AUTH_PARAMS% /P"%ONEC_PASSWORD%"

"%ONEC_PATH%" DESIGNER %IB_PARAMS% %AUTH_PARAMS% /DisableStartupDialogs /Out"$tempLog" /DumpConfigToFiles "$tempDir" -ConfigurationExtension -force
exit /b %ERRORLEVEL%
"@
    
    $batContent | Out-File -FilePath $tempBat -Encoding ASCII
    
    try {
        $process = Start-Process -FilePath $tempBat -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[OK] База доступна" -ForegroundColor Green
            $checks.Database = $true
        } else {
            Write-Host "[FAIL] Не удалось подключиться (код: $($process.ExitCode))" -ForegroundColor Red
            if (Test-Path $tempLog) {
                $log = Get-Content $tempLog -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($log) {
                    Write-Host "[WARN] Ошибка:" -ForegroundColor Yellow
                    ($log -split "`n" | Select-Object -First 3) | ForEach-Object {
                        if ($_.Trim()) { Write-Host "     $_" -ForegroundColor Yellow }
                    }
                }
            }
        }
    } finally {
        if (Test-Path $tempBat) { Remove-Item $tempBat -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path $tempLog) { Remove-Item $tempLog -Force -ErrorAction SilentlyContinue }
    }
} elseif ($Server -or $Database) {
    Write-Host "[WARN] Проверка базы пропущена (не все параметры)" -ForegroundColor Yellow
}

# Итог
Write-Host ""
Write-Host "=== Результаты ===" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true
foreach ($check in $checks.GetEnumerator() | Sort-Object Name) {
    if ($check.Value) {
        Write-Host "[OK] $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($check.Key)" -ForegroundColor Red
        $allPassed = $false
    }
}

Write-Host ""

if ($allPassed) {
    Write-Host "[SUCCESS] Все проверки пройдены!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[ERROR] Некоторые проверки не пройдены" -ForegroundColor Red
    exit 1
}
