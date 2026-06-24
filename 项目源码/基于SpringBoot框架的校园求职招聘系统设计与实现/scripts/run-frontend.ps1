param(
  [Parameter(Mandatory = $true)]
  [string]$Root
)

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$logDir = Join-Path $rootPath 'logs'
$logFile = Join-Path $logDir 'frontend.log'
$frontendPath = Join-Path $rootPath 'frontend'

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
Set-Location -LiteralPath $frontendPath

"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] frontend starting" | Out-File -FilePath $logFile -Append -Encoding utf8
$viteBin = Join-Path $frontendPath 'node_modules\vite\bin\vite.js'
& node $viteBin --host 127.0.0.1 *>> $logFile
$exitCode = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] frontend exited: $exitCode" | Out-File -FilePath $logFile -Append -Encoding utf8
exit $exitCode
