# ============================================================
#  MrHunter installer (Windows PowerShell)
#  Usage:
#    Project:  irm .../install.ps1 | iex
#    Global :  & ([scriptblock]::Create((irm .../install.ps1))) -Global
# ============================================================
param([switch]$Global)

$ErrorActionPreference = "Stop"
$Repo   = "https://github.com/TheWildEye/MrHunter2.git"
$Branch = "main"
$Tmp    = Join-Path $env:TEMP ("mrhunter-" + [guid]::NewGuid().ToString("N"))

Write-Host "==============================================="
Write-Host " Installing MrHunter for OpenCode"
Write-Host "==============================================="

git clone --depth 1 --branch $Branch $Repo $Tmp | Out-Null

if ($Global) {
    $Dest = Join-Path $HOME ".config/opencode"
    New-Item -ItemType Directory -Force -Path "$Dest/agent", "$Dest/command", "$Dest/skill" | Out-Null
    Copy-Item -Recurse -Force "$Tmp/MrHunter/.opencode/agents/*"   "$Dest/agent/"
    Copy-Item -Recurse -Force "$Tmp/MrHunter/.opencode/commands/*" "$Dest/command/"
    Copy-Item -Recurse -Force "$Tmp/MrHunter/.opencode/skills/*"   "$Dest/skill/"
    Write-Host " Installed globally to $Dest"
    Write-Host " Note: merge the 'agent' block from MrHunter/opencode.json into $Dest/opencode.json"
}
else {
    New-Item -ItemType Directory -Force -Path "./.opencode" | Out-Null
    Copy-Item -Recurse -Force "$Tmp/MrHunter/.opencode/*" "./.opencode/"
    if (-not (Test-Path "./opencode.json")) { Copy-Item "$Tmp/MrHunter/opencode.json" "./opencode.json" }
    if (-not (Test-Path "./AGENTS.md"))     { Copy-Item "$Tmp/MrHunter/AGENTS.md"     "./AGENTS.md" }
    Write-Host " Installed into ./.opencode/"
}

Remove-Item -Recurse -Force $Tmp

Write-Host "==============================================="
Write-Host " Done. Open OpenCode and run /mrhunter-quick-scan"
Write-Host "==============================================="
