# Sanitize files - remove private information

$replacements = @{
    # IP addresses
    'http://192\.168\.0\.101' = 'http://YOUR_SERVER'
    'http://192\.168\.0\.105' = 'http://YOUR_SERVER'
    'http://192\.168\.0\.106' = 'http://YOUR_SERVER'
    'http://192\.168\.0\.107' = 'http://YOUR_SERVER'
    'http://192\.168\.0\.108' = 'http://YOUR_SERVER'
    'http://192\.168\.0\.109' = 'http://YOUR_SERVER'
    'http://192\.168\.0\.111' = 'http://YOUR_SERVER'
    '192\.168\.0\.99' = 'YOUR_PROXMOX_HOST'
    '192\.168\.0\.101' = 'YOUR_SERVER'
    '192\.168\.0\.105' = 'YOUR_MCP_SERVER'
    '192\.168\.0\.106' = 'YOUR_RLM_SERVER'
    '192\.168\.0\.107' = 'YOUR_SERVER'
    '192\.168\.0\.108' = 'YOUR_OLLAMA_SERVER'
    '192\.168\.0\.109' = 'YOUR_RLM_HOST'
    '192\.168\.0\.111' = 'YOUR_MCP_SERVER'

    # Project-specific MCP servers
    'user-kaf-codemetadata-codesearch' = 'user-PROJECT-codemetadata-codesearch (project-specific MCP)'
    'user-kaf-codemetadata-metadatasearch' = 'user-PROJECT-codemetadata-metadatasearch (project-specific MCP)'
    'user-kaf-graph-cypher' = 'user-PROJECT-graph-cypher (project-specific MCP)'
    'kaf-codemetadata' = 'PROJECT-codemetadata (project-specific MCP)'
    'kaf-graph' = 'PROJECT-graph (project-specific MCP)'
    'minimkg-enhanced' = 'PROJECT-codemetadata (project-specific MCP)'

    # Paths
    '(?i)C:\\Users\\Arman' = 'C:\Users\YOUR_USERNAME'
    '/home/arman' = '/home/YOUR_USERNAME'

    # Infrastructure
    'CT 105' = 'CT XXX'
    'CT 106' = 'CT XXX'
    'CT 108' = 'CT XXX'
    'LXC 104' = 'LXC XXX'
    'homeserver' = 'YOUR_SERVER'
}

$files = @()
$files += Get-ChildItem ".cursor\agents\*.md" -Recurse -ErrorAction SilentlyContinue
$files += Get-ChildItem ".cursor\rules\*.mdc" -Recurse -ErrorAction SilentlyContinue
$files += Get-ChildItem ".cursor\skills\*.md" -Recurse -ErrorAction SilentlyContinue
$files += Get-ChildItem ".claude\skills\*.md" -Recurse -ErrorAction SilentlyContinue
$files += Get-ChildItem ".claude\docs\*.md" -Recurse -ErrorAction SilentlyContinue
$files += Get-ChildItem "CLAUDE.md" -ErrorAction SilentlyContinue
$files += Get-ChildItem ".mcp.json" -ErrorAction SilentlyContinue
$files += Get-ChildItem "README.md" -ErrorAction SilentlyContinue

Write-Host "Processing $($files.Count) files..."

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $modified = $false
    
    foreach ($pattern in $replacements.Keys) {
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacements[$pattern]
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Sanitized: $($file.Name)"
    }
}

Write-Host "Done!"
