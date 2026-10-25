$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE 'dugg-link'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item (Join-Path $root 'known_hosts') (Join-Path $dest 'known_hosts') -Force

$key = Join-Path $dest 'mac_ed25519'
$known = Join-Path $dest 'known_hosts'
$proxy = Join-Path $dest 'tlsproxy.exe'
$source = Join-Path $root 'tlsproxy.cs'
if (-not (Test-Path $source)) {
  $source = Join-Path $dest 'samsung-link\tlsproxy.cs'
}
if (-not (Test-Path $proxy)) {
  & "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo "/out:$proxy" $source
}

$remote = 'shaurya1234duggal5678@shaurya1234s-macbook-pro.tailc80c27.ts.net'
$proxyCmd = $proxy.Replace('\', '/')
Write-Host 'samsung-link: visible SSH forward to the Mac. Close this window to stop.'
while ($true) {
  Write-Host ("{0} connecting" -f (Get-Date -Format o))
  & ssh.exe -i $key -o IdentitiesOnly=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -o "UserKnownHostsFile=$known" -o StrictHostKeyChecking=yes -o "ProxyCommand=$proxyCmd" -N -R '127.0.0.1:2222:127.0.0.1:22' -p 443 $remote
  Write-Host ("{0} ssh exited {1}, retry in 5s" -f (Get-Date -Format o), $LASTEXITCODE)
  Start-Sleep -Seconds 5
}
