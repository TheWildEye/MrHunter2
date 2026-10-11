# ==============================================================================
# MrHunter - OpenCode Installation Script (Windows PowerShell)
# ==============================================================================
# Installs the OpenCode agents, slash commands, and skills into a project
# (./.opencode) or globally ($HOME/.config/opencode).
#
# Usage:
#   Project-level (current workspace):
#     .\install.ps1
#
#   Global-level (available in every OpenCode project):
#     .\install.ps1 -Global
# ==============================================================================

param(
    [switch]$Global
)

$ErrorActionPreference = "Stop"

# --- CONFIGURATION (Change this to match your repository URL) ---
$GithubUser = "TheWildEye"
$GithubRepo = "MrHunter2"
$Branch     = "main"
$RepoUrl    = "https://github.com/$GithubUser/$GithubRepo.git"
# ================================================================

$TmpDir = Join-Path $env:TEMP ("mrhunter-" + [guid]::NewGuid().ToString("N"))

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " Installing MrHunter for OpenCode" -ForegroundColor Cyan
Write-Host " Source: $GithubUser/$GithubRepo @ $Branch" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

git clone --depth 1 --branch $Branch $RepoUrl $TmpDir | Out-Null

if ($Global) {
    $Dest = Join-Path $HOME ".config/opencode"
    New-Item -ItemType Directory -Force -Path "$Dest/agent", "$Dest/command", "$Dest/skill" | Out-Null
    Copy-Item -Recurse -Force "$TmpDir/.opencode/agents/*"   "$Dest/agent/"
    Copy-Item -Recurse -Force "$TmpDir/.opencode/commands/*" "$Dest/command/"
    Copy-Item -Recurse -Force "$TmpDir/.opencode/skills/*"   "$Dest/skill/"
    Write-Host "Installed agents, commands, and skills to $Dest"
    Write-Host "NOTE: merge the 'agent' block from $TmpDir/opencode.json into $Dest/opencode.json"
}
else {
    New-Item -ItemType Directory -Force -Path "./.opencode" | Out-Null
    Copy-Item -Recurse -Force "$TmpDir/.opencode/*" "./.opencode/"
    if (-not (Test-Path "./opencode.json")) { Copy-Item "$TmpDir/opencode.json" "./opencode.json" }
    if (-not (Test-Path "./AGENTS.md"))     { Copy-Item "$TmpDir/AGENTS.md"     "./AGENTS.md" }
    Write-Host "Installed OpenCode plugin into ./.opencode/"
}

Remove-Item -Recurse -Force $TmpDir

Write-Host "===============================================" -ForegroundColor Green
Write-Host " Installation Complete!" -ForegroundColor Green
Write-Host " Restart OpenCode, then run any of:" -ForegroundColor Green
Write-Host "   /mrhunter-security-assess   - Full SAST + DAST + secrets + compliance scan"
Write-Host "   /mrhunter-compliance-audit  - Deep Indian regulatory compliance audit"
Write-Host "   /mrhunter-quick-scan        - Rapid SAST & secret checks"
Write-Host "   /mrhunter-fix-issue         - Interactively fix a specific vulnerability"
Write-Host "===============================================" -ForegroundColor Green
