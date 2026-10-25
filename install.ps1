$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE 'dugg-link'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

Copy-Item (Join-Path $root 'link.ps1') (Join-Path $dest 'link.ps1') -Force
Copy-Item (Join-Path $root 'known_hosts') (Join-Path $dest 'known_hosts') -Force

$key = Join-Path $dest 'mac_ed25519'
if (-not (Test-Path $key)) {
  & ssh-keygen -t ed25519 -f $key -N ([string]::Empty) -C 'shaurya@samsungbook4'
}

& icacls $key /inheritance:r | Out-Null
& icacls $key /grant:r "${env:USERNAME}:(R)" | Out-Null

$startup = [Environment]::GetFolderPath('Startup')
$launcher = Join-Path $startup 'samsung-link.cmd'
@(
  '@echo off'
  "start `"samsung-link`" powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File `"$dest\link.ps1`""
) | Set-Content -Path $launcher -Encoding ascii

Write-Output 'PUBLIC KEY:'
Get-Content -Raw (Join-Path $dest 'mac_ed25519.pub')

$already = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" |
  Where-Object { $_.CommandLine -like '*dugg-link\link.ps1*' }
if (-not $already) {
  Start-Process powershell.exe -ArgumentList @(
    '-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $dest 'link.ps1')
  )
}

Write-Output 'WINDOW STARTED'
