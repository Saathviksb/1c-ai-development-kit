# Sanitize files - remove private information

$replacements = @{
    # IP addresses (except localhost)
    'http://192\.168\.0\.101' = 'http://YOUR_SERVER'
    '192\.168\.0\.101' = 'YOUR_SERVER'
    
    # Project-specific MCP servers
    'user-kaf-codemetadata-codesearch' = 'user-PROJECT-codemetadata-codesearch (project-specific MCP)'
    'user-kaf-codemetadata-metadatasearch' = 'user-PROJECT-codemetadata-metadatasearch (project-specific MCP)'
    'user-kaf-graph-cypher' = 'user-PROJECT-graph-cypher (project-specific MCP)'
    'kaf-codemetadata' = 'PROJECT-codemetadata (project-specific MCP)'
    'kaf-graph' = 'PROJECT-graph (project-specific MCP)'
    
    # Paths (case-insensitive in PowerShell, so one pattern is enough)
    '(?i)C:\\Users\\Arman' = 'C:\Users\YOUR_USERNAME'
    '/home/arman' = '/home/YOUR_USERNAME'
    
    # Domains
    'gitea\.yourdomain\.com' = 'gitea.yourdomain.com'
    'homeserver' = 'YOUR_SERVER'
}

$files = @()
$files += Get-ChildItem ".cursor\agents\*.md" -Recurse
$files += Get-ChildItem ".cursor\rules\*.mdc" -Recurse
$files += Get-ChildItem ".cursor\skills\*.md" -Recurse
$files += Get-ChildItem "README.md"

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
