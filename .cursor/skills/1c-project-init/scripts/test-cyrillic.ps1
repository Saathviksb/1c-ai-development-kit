# Test script for Cyrillic encoding in PowerShell
# Tests console output and file writing with Cyrillic characters

param(
    [string]$TestDir = ".\test-cyrillic-output"
)

$ErrorActionPreference = "Stop"

# Set console encoding for Cyrillic I/O
chcp 65001 > $null

# Prepare UTF-8 BOM encoding
$utf8bom = New-Object System.Text.UTF8Encoding($true)

Write-Host ""
Write-Host "=== Cyrillic Encoding Test ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Console output
Write-Host "[Test 1/3] Console output..." -ForegroundColor Yellow
$testText = "Test Cyrillic: ABVGDEJOZHZIJKLMNOPRSTUFHCCHSHSHHJYJEJUJA"
Write-Host "  $testText" -ForegroundColor Green
Write-Host "  OK If you see correct Cyrillic above, console encoding works" -ForegroundColor Green
Write-Host ""

# Test 2: File writing
Write-Host "[Test 2/3] File writing..." -ForegroundColor Yellow

if (Test-Path $TestDir) {
    Remove-Item $TestDir -Recurse -Force
}
New-Item -ItemType Directory -Path $TestDir -Force | Out-Null

$testFile = Join-Path $TestDir "test-cyrillic.txt"
$fileContent = "Test Cyrillic in file`r`n"
$fileContent += "======================`r`n"
$fileContent += "`r`n"
$fileContent += "Alphabet: ABVGDEJOZHZIJKLMNOPRSTUFHCCHSHSHHJYJEJUJA`r`n"
$fileContent += "Numbers: 1234567890`r`n"
$fileContent += "Latin: ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`r`n"
$fileContent += "`r`n"
$fileContent += "Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n"

[System.IO.File]::WriteAllText($testFile, $fileContent, $utf8bom)
Write-Host "  OK File created: $testFile" -ForegroundColor Green

# Test 3: BOM verification
Write-Host "[Test 3/3] BOM verification..." -ForegroundColor Yellow

$bytes = [System.IO.File]::ReadAllBytes($testFile)
if ($bytes.Length -ge 3) {
    $bom = "{0:X2} {1:X2} {2:X2}" -f $bytes[0], $bytes[1], $bytes[2]
    
    if ($bom -eq "EF BB BF") {
        Write-Host "  OK UTF-8 BOM verified: $bom" -ForegroundColor Green
    } else {
        Write-Host "  ERROR Invalid BOM: $bom (expected EF BB BF)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  ERROR File too small to check BOM" -ForegroundColor Red
    exit 1
}

# Test 4: Read back and verify
Write-Host ""
Write-Host "[Test 4/4] Read back verification..." -ForegroundColor Yellow

$readContent = [System.IO.File]::ReadAllText($testFile, $utf8bom)
if ($readContent -match "ABVGDEJOZHZIJKLMNOPRSTUFHCCHSHSHHJYJEJUJA") {
    Write-Host "  OK Cyrillic read correctly from file" -ForegroundColor Green
} else {
    Write-Host "  ERROR Cyrillic corrupted when reading" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== All Tests Passed ===" -ForegroundColor Green
Write-Host ""
Write-Host "Test files created in: $TestDir" -ForegroundColor Cyan
Write-Host "You can open $testFile in any editor to verify Cyrillic displays correctly" -ForegroundColor Cyan
Write-Host ""
Write-Host "To clean up: Remove-Item '$TestDir' -Recurse -Force" -ForegroundColor Gray
Write-Host ""
