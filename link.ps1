$ErrorActionPreference = 'Continue'
$dest = Join-Path $env:USERPROFILE 'dugg-link'
$key = Join-Path $dest 'mac_ed25519'
$known = Join-Path $dest 'known_hosts'
$remote = 'shaurya1234duggal5678@shaurya1234s-macbook-pro.tailc80c27.ts.net'

Write-Host 'samsung-link: visible SSH forward to the Mac. Close this window to stop.'
while ($true) {
  Write-Host ("{0} connecting" -f (Get-Date -Format o))
  & ssh.exe -i $key -o IdentitiesOnly=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -o "UserKnownHostsFile=$known" -o StrictHostKeyChecking=yes -N -R '127.0.0.1:2222:127.0.0.1:22' -p 8443 $remote
  Write-Host ("{0} ssh exited {1}, retry in 5s" -f (Get-Date -Format o), $LASTEXITCODE)
  Start-Sleep -Seconds 5
}
