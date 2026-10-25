$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dest = Join-Path $env:USERPROFILE 'dugg-link'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item (Join-Path $root 'known_hosts') (Join-Path $dest 'known_hosts') -Force
Copy-Item (Join-Path $root 'tlsproxy.py') (Join-Path $dest 'tlsproxy.py') -Force

$key = Join-Path $dest 'mac_ed25519'
$known = Join-Path $dest 'known_hosts'
$proxy = Join-Path $dest 'tlsproxy.exe'
$source = Join-Path $root 'tlsproxy.cs'
if (-not (Test-Path $source)) {
  $source = Join-Path $dest 'samsung-link\tlsproxy.cs'
}

function Find-Tool([string[]]$names, [string[]]$paths) {
  foreach ($path in $paths) {
    if ($path -and (Test-Path $path)) { return (Resolve-Path $path).Path }
  }
  foreach ($name in $names) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }
  }
  return $null
}

$openssl = Find-Tool @('openssl.exe') @(
  "$env:ProgramFiles\Git\usr\bin\openssl.exe",
  "$env:ProgramFiles\Git\mingw64\bin\openssl.exe",
  "$env:LocalAppData\Programs\Git\usr\bin\openssl.exe",
  "$env:LocalAppData\Programs\Git\mingw64\bin\openssl.exe"
)
$python = Find-Tool @('py.exe', 'python.exe', 'python3.exe') @(
  "$env:LocalAppData\Programs\Python\Python313\python.exe",
  "$env:LocalAppData\Programs\Python\Python312\python.exe",
  "$env:LocalAppData\Programs\Python\Python311\python.exe",
  "$env:LocalAppData\Python\bin\python.exe"
)

$pathFile = Join-Path $dest 'proxy.path'
if ($openssl) {
  $args = 's_client -connect shaurya1234s-macbook-pro.tailc80c27.ts.net:443 -servername shaurya1234s-macbook-pro.tailc80c27.ts.net -tls1_2 -quiet'
  Set-Content -Path $pathFile -Value @('openssl', $openssl, $args) -Encoding Ascii
  Write-Host "samsung-link: using $openssl"
} elseif ($python) {
  $script = Join-Path $dest 'tlsproxy.py'
  Set-Content -Path $pathFile -Value @('python', $python, $script) -Encoding Ascii
  Write-Host "samsung-link: using $python"
} else {
  Write-Host 'samsung-link: neither openssl.exe nor python.exe was found.'
  exit 1
}

Remove-Item $proxy -Force -ErrorAction SilentlyContinue
& "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo "/out:$proxy" $source
if (-not (Test-Path $proxy)) {
  Write-Host 'samsung-link: could not compile tlsproxy.exe'
  exit 1
}

$remote = 'shaurya1234duggal5678@shaurya1234s-macbook-pro.tailc80c27.ts.net'
$proxyCmd = $proxy.Replace('\', '/')
Write-Host 'samsung-link: visible SSH forward to the Mac. Close this window to stop.'
while ($true) {
  Write-Host ("{0} connecting" -f (Get-Date -Format o))
  & ssh.exe -v -i $key -o IdentitiesOnly=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -o "UserKnownHostsFile=$known" -o StrictHostKeyChecking=yes -o "ProxyCommand=$proxyCmd" -N -R '127.0.0.1:2222:127.0.0.1:22' -p 443 $remote
  Write-Host ("{0} ssh exited {1}, retry in 5s" -f (Get-Date -Format o), $LASTEXITCODE)
  Start-Sleep -Seconds 5
}
