param(
  [Parameter(Mandatory = $true)]
  [string]$Root,

  [Parameter(Mandatory = $true)]
  [ValidateSet('backend', 'frontend')]
  [string]$Service
)

$ErrorActionPreference = 'Stop'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$scriptDir = Join-Path $rootPath 'scripts'
$runDir = Join-Path $rootPath '.run'
$logDir = Join-Path $rootPath 'logs'

New-Item -ItemType Directory -Force -Path $runDir, $logDir | Out-Null

$runner = Join-Path $scriptDir "run-$Service.ps1"
if (-not (Test-Path -LiteralPath $runner)) {
  throw "Runner script not found: $runner"
}

$pidFile = Join-Path $runDir "$Service.pid"
$argumentList = '-NoProfile -ExecutionPolicy Bypass -File "{0}" -Root "{1}"' -f $runner, $rootPath

$process = Start-Process `
  -FilePath 'powershell.exe' `
  -ArgumentList $argumentList `
  -WorkingDirectory $rootPath `
  -WindowStyle Hidden `
  -PassThru

Set-Content -LiteralPath $pidFile -Value $process.Id -Encoding ASCII
Write-Output $process.Id
