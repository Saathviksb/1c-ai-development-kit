# 1c-project-init v1.0 — Initialize or enrich a 1C project from AI workspace
param(
    [Parameter(Mandatory)]
    [string]$TargetPath,

    [ValidateSet("new", "enrich", "auto")]
    [string]$Mode = "auto"
)

$ErrorActionPreference = "Stop"
$WorkspacePath = "$PSScriptRoot\..\..\..\.."  # scripts/ -> 1c-project-init/ -> skills/ -> .claude/ -> workspace root
$WorkspacePath = (Resolve-Path $WorkspacePath).Path

$SkillsSrc = Join-Path $WorkspacePath ".claude\skills"
$DocsSrc   = Join-Path $WorkspacePath ".claude\docs"
$SkillsDst = Join-Path $TargetPath ".claude\skills"
$DocsDst   = Join-Path $TargetPath ".claude\docs"

# Auto-detect mode
if ($Mode -eq "auto") {
    $Mode = if (Test-Path $SkillsDst) { "enrich" } else { "new" }
}

Write-Host "Mode: $Mode" -ForegroundColor Cyan
Write-Host "Source: $WorkspacePath" -ForegroundColor Gray
Write-Host "Target: $TargetPath" -ForegroundColor Gray
Write-Host ""

$created = @()
$updated = @()
$skipped = @()

# ── Helper ──────────────────────────────────────────────────────────────────

function Copy-IfNewer {
    param([string]$Src, [string]$Dst, [string]$Label)
    if (-not (Test-Path $Dst)) {
        $null = New-Item -ItemType File -Path $Dst -Force
        Copy-Item -Path $Src -Destination $Dst -Force
        $script:created += $Label
    } else {
        $srcHash = (Get-FileHash $Src -Algorithm MD5).Hash
        $dstHash = (Get-FileHash $Dst -Algorithm MD5).Hash
        if ($srcHash -ne $dstHash) {
            Copy-Item -Path $Src -Destination $Dst -Force
            $script:updated += $Label
        } else {
            $script:skipped += $Label
        }
    }
}

# ── Skills ───────────────────────────────────────────────────────────────────

Write-Host "Syncing skills..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Path $SkillsDst -Force

Get-ChildItem -Path $SkillsSrc -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($SkillsSrc.Length + 1)
    # Skip the init skill itself to avoid self-copy issues
    if ($rel -like "1c-project-init*") { return }
    $dst = Join-Path $SkillsDst $rel
    $null = New-Item -ItemType Directory -Path (Split-Path $dst) -Force
    Copy-IfNewer -Src $_.FullName -Dst $dst -Label "skills/$rel"
}

# ── Docs (always overwrite — platform specs are source-of-truth) ─────────────

Write-Host "Syncing docs..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Path $DocsDst -Force

Get-ChildItem -Path $DocsSrc -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($DocsSrc.Length + 1)
    $dst = Join-Path $DocsDst $rel
    $null = New-Item -ItemType Directory -Path (Split-Path $dst) -Force
    Copy-Item -Path $_.FullName -Destination $dst -Force
    $script:updated += "docs/$rel"
}

# ── New project scaffold ──────────────────────────────────────────────────────

if ($Mode -eq "new") {
    Write-Host "Creating project scaffold..." -ForegroundColor Yellow

    $dirs = @(
        "src",
        "openspec\changes",
        "openspec\specs",
        "openspec\archive",
        "docs"
    )
    foreach ($d in $dirs) {
        $path = Join-Path $TargetPath $d
        if (-not (Test-Path $path)) {
            $null = New-Item -ItemType Directory -Path $path -Force
            $created += "dir: $d"
        }
    }

    # openspec/project.md placeholder
    $projectMd = Join-Path $TargetPath "openspec\project.md"
    if (-not (Test-Path $projectMd)) {
        "# Project Context`n`n<!-- AI: fill this with project goals, conventions, architecture -->`n" | Set-Content -Path $projectMd -Encoding UTF8
        $created += "openspec/project.md"
    }
}

# ── .claude/settings.json ────────────────────────────────────────────────────

$settingsPath = Join-Path $TargetPath ".claude\settings.json"
if (-not (Test-Path $settingsPath)) {
    $null = New-Item -ItemType Directory -Path (Split-Path $settingsPath) -Force
    @'
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(powershell *)",
      "mcp__rlm-toolkit__*"
    ]
  }
}
'@ | Set-Content -Path $settingsPath -Encoding UTF8
    $created += ".claude/settings.json"
}

# ── Gitea remote setup ────────────────────────────────────────────────────────

$GiteaUrl   = "http://YOUR_GITEA_SERVER:3000"
$GiteaToken = "YOUR_GITEA_TOKEN"
$ProjectName = Split-Path $TargetPath -Leaf

Write-Host "Setting up Gitea remote..." -ForegroundColor Yellow

if (Test-Path (Join-Path $TargetPath ".git")) {
    $remotes = & git -C $TargetPath remote 2>$null
    if ($remotes -notcontains "gitea") {
        # Create repo in Gitea if not exists
        $body = @{ name = $ProjectName; private = $true; auto_init = $false } | ConvertTo-Json
        try {
            $null = Invoke-RestMethod -Method Post -Uri "$GiteaUrl/api/v1/user/repos" `
                -Headers @{ Authorization = "token $GiteaToken"; "Content-Type" = "application/json" } `
                -Body $body -ErrorAction SilentlyContinue
        } catch {}

        $remoteUrl = "http://admin:YOUR_GITEA_PASSWORD@YOUR_GITEA_SERVER:3000/admin/$ProjectName.git"
        & git -C $TargetPath remote add gitea $remoteUrl 2>$null
        $created += "git remote: gitea"
        Write-Host "  + Added gitea remote: $remoteUrl" -ForegroundColor Green
    } else {
        Write-Host "  gitea remote already exists" -ForegroundColor Gray
    }
} else {
    Write-Host "  Not a git repo, skipping gitea remote" -ForegroundColor Gray
}

# ── bsl-lsp-bridge ────────────────────────────────────────────────────────────

Write-Host "Checking bsl-lsp-bridge..." -ForegroundColor Yellow
$containerName = "mcp-lsp-$ProjectName"
$containerRunning = ssh root@YOUR_GITEA_SERVER "docker ps -q --filter name=$containerName" 2>$null
if (-not $containerRunning) {
    ssh root@YOUR_GITEA_SERVER "bash /opt/start-bsl-lsp.sh $ProjectName $ProjectName/src" 2>$null
    $created += "bsl-lsp-bridge: $containerName"
    Write-Host "  + Started container: $containerName" -ForegroundColor Green
} else {
    Write-Host "  $containerName already running" -ForegroundColor Gray
}

# ── Summary ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Green
Write-Host "Mode: $Mode | Target: $TargetPath"
Write-Host ""

if ($created.Count -gt 0) {
    Write-Host "Created ($($created.Count)):" -ForegroundColor Green
    $created | Select-Object -First 20 | ForEach-Object { Write-Host "  + $_" }
    if ($created.Count -gt 20) { Write-Host "  ... and $($created.Count - 20) more" }
}
if ($updated.Count -gt 0) {
    Write-Host "Updated ($($updated.Count)):" -ForegroundColor Yellow
    $updated | Where-Object { $_ -notlike "docs/*" } | Select-Object -First 10 | ForEach-Object { Write-Host "  ~ $_" }
    $docsCount = ($updated | Where-Object { $_ -like "docs/*" }).Count
    if ($docsCount -gt 0) { Write-Host "  ~ docs: $docsCount files refreshed" }
}
if ($skipped.Count -gt 0) {
    Write-Host "Unchanged: $($skipped.Count) skills" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Next steps for AI: generate CLAUDE.md, .mcp.json, .v8-project.json" -ForegroundColor Cyan
