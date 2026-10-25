$ErrorActionPreference = 'Continue'
$dest = Join-Path $env:USERPROFILE 'dugg-link'
$base = 'https://shaurya1234s-macbook-pro.tailc80c27.ts.net'
$tokenPath = Join-Path $dest 'agent.token'
if (-not (Test-Path $tokenPath)) {
  Write-Host 'samsung-link: put the pairing token in agent.token first.'
  exit 1
}
$token = (Get-Content -Raw $tokenPath).Trim()
Write-Host 'samsung-link: visible link to the Mac over HTTPS. Close this window to stop.'
while ($true) {
  try {
    $headers = @{ Authorization = "Bearer $token" }
    $job = Invoke-RestMethod -Headers $headers -Uri "$base/poll" -TimeoutSec 40
    if ($job.id) {
      Write-Host ("{0} {1}" -f (Get-Date -Format o), $job.id)
      $out = ''
      $code = 0
      try {
        $out = (Invoke-Expression $job.cmd 2>&1 | Out-String)
      } catch {
        $out = $_.Exception.Message
        $code = 1
      }
      if ($out.Length -gt 150000) { $out = $out.Substring(0, 150000) }
      $body = @{ id = $job.id; output = $out; code = $code } | ConvertTo-Json -Compress
      Invoke-RestMethod -Method POST -Headers $headers -Uri "$base/result" -Body $body -ContentType 'application/json; charset=utf-8' -TimeoutSec 40 | Out-Null
    }
  } catch {
    Write-Host $_.Exception.Message
    Start-Sleep -Seconds 3
  }
}
