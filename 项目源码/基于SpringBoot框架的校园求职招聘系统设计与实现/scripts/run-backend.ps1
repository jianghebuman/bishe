param(
  [Parameter(Mandatory = $true)]
  [string]$Root
)

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$logDir = Join-Path $rootPath 'logs'
$logFile = Join-Path $logDir 'backend.log'

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
Set-Location -LiteralPath $rootPath

"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] backend starting" | Out-File -FilePath $logFile -Append -Encoding utf8
& mvn -f 'backend\pom.xml' spring-boot:run *>> $logFile
$exitCode = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] backend exited: $exitCode" | Out-File -FilePath $logFile -Append -Encoding utf8
exit $exitCode
