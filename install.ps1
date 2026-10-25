$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE 'dugg-link'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
if (-not (Test-Path (Join-Path $dest 'agent.token'))) {
  Write-Output 'MISSING TOKEN'
  exit 1
}
Start-Process powershell.exe -ArgumentList @(
  '-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $root 'link.ps1')
)
Write-Output 'WINDOW STARTED'
