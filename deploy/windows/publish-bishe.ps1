param(
  [switch]$SkipBackend,
  [switch]$SkipFrontend,
  [switch]$SkipNpmInstall
)

$ErrorActionPreference = 'Stop'

$Repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$BackendDir = Get-ChildItem -Path $Repo -Recurse -Directory -Filter 'backend' |
  Where-Object { Test-Path (Join-Path $_.FullName 'pom.xml') } |
  Select-Object -First 1
$FrontendDir = Get-ChildItem -Path $Repo -Recurse -Directory -Filter 'frontend' |
  Where-Object { Test-Path (Join-Path $_.FullName 'package.json') } |
  Select-Object -First 1
$DbFile = Get-ChildItem -Path $Repo -Recurse -File -Filter 'update-data.sql' |
  Where-Object { $_.FullName -notmatch '\\(target|node_modules|dist)\\' } |
  Select-Object -First 1

if ($null -eq $BackendDir) { throw "Backend directory with pom.xml was not found under: $Repo" }
if ($null -eq $FrontendDir) { throw "Frontend directory with package.json was not found under: $Repo" }
if ($null -eq $DbFile) { throw "Database update script was not found under: $Repo" }

$Backend = $BackendDir.FullName
$Frontend = $FrontendDir.FullName
$Src = Split-Path $Backend -Parent
$DbScript = $DbFile.FullName
$UploadDir = Join-Path $Src 'upload'
$ReleaseRoot = Join-Path $Repo 'deploy\releases'
$Stage = Join-Path $ReleaseRoot '_stage'

function Invoke-Step {
  param(
    [string]$Name,
    [scriptblock]$Action
  )
  Write-Host ""
  Write-Host "==> $Name" -ForegroundColor Cyan
  & $Action
}

function Invoke-CommandChecked {
  param(
    [string]$FilePath,
    [string[]]$Arguments
  )
  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$FilePath failed with exit code $LASTEXITCODE"
  }
}

function Compress-ArchiveWithRetry {
  param(
    [string]$Path,
    [string]$DestinationPath
  )

  $lastError = $null
  for ($i = 1; $i -le 5; $i++) {
    try {
      Compress-Archive -Path $Path -DestinationPath $DestinationPath -Force
      return
    } catch {
      $lastError = $_
      Start-Sleep -Seconds 2
    }
  }

  throw $lastError
}

$Commit = 'unknown'
try {
  Push-Location $Repo
  $Commit = (& git rev-parse --short=12 HEAD).Trim()
  Pop-Location
} catch {
  Pop-Location -ErrorAction SilentlyContinue
}

$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Version = "$Stamp-$Commit"
$ZipName = "bishe-release-$Version.zip"
$ZipPath = Join-Path $ReleaseRoot $ZipName

if (!$SkipBackend) {
  Invoke-Step 'Build backend jar' {
    Push-Location $Backend
    Invoke-CommandChecked 'mvn' @('clean', 'package', '-DskipTests')
    Pop-Location
  }
}

if (!$SkipFrontend) {
  Invoke-Step 'Build frontend dist' {
    Push-Location $Frontend
    if (!$SkipNpmInstall) {
      Invoke-CommandChecked 'npm' @('install')
    }
    Invoke-CommandChecked 'npm' @('run', 'build')
    Pop-Location
  }
}

$Jar = Join-Path $Backend 'target\campus-recruitment.jar'
$Dist = Join-Path $Frontend 'dist'
if (!(Test-Path $Jar)) { throw "Jar not found: $Jar" }
if (!(Test-Path (Join-Path $Dist 'index.html'))) { throw "Frontend dist not found: $Dist" }

Invoke-Step 'Create release package' {
  New-Item -ItemType Directory -Force -Path $ReleaseRoot | Out-Null
  if (Test-Path $Stage) {
    Remove-Item -LiteralPath $Stage -Recurse -Force
  }

  New-Item -ItemType Directory -Force -Path (Join-Path $Stage 'backend') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $Stage 'frontend') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $Stage 'database') | Out-Null

  Copy-Item -LiteralPath $Jar -Destination (Join-Path $Stage 'backend\campus-recruitment.jar') -Force
  Copy-Item -LiteralPath $Dist -Destination (Join-Path $Stage 'frontend\dist') -Recurse -Force
  Copy-Item -LiteralPath $DbScript -Destination (Join-Path $Stage 'database') -Force

  if (Test-Path $UploadDir) {
    Copy-Item -LiteralPath $UploadDir -Destination (Join-Path $Stage 'upload') -Recurse -Force
  }

  $VersionText = @(
    "version=$Version"
    "commit=$Commit"
    "built_at=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
  ) -join "`n"
  Set-Content -LiteralPath (Join-Path $Stage 'VERSION.txt') -Value $VersionText -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $Stage 'frontend\dist\version.txt') -Value $VersionText -Encoding UTF8

  if (Test-Path $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
  }
  Compress-ArchiveWithRetry -Path (Join-Path $Stage '*') -DestinationPath $ZipPath
  Remove-Item -LiteralPath $Stage -Recurse -Force
}

Write-Host ""
Write-Host "Release package created:" -ForegroundColor Green
Write-Host $ZipPath
Write-Host ""
Write-Host "Upload it to the server, for example: /www/releases/$ZipName"
Write-Host "Deploy without database update:"
Write-Host "/www/campus-recruitment/scripts/deploy-bishe-release.sh /www/releases/$ZipName"
Write-Host "Deploy with database update:"
Write-Host "/www/campus-recruitment/scripts/deploy-bishe-release.sh /www/releases/$ZipName --db"
