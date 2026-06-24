param(
  [Parameter(Mandatory = $true)]
  [string]$Root
)

$ErrorActionPreference = 'SilentlyContinue'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$runDir = Join-Path $rootPath '.run'

function Stop-ProcessTree {
  param([int]$ProcessId)

  if ($ProcessId -gt 0) {
    & taskkill.exe /PID $ProcessId /T /F | Out-Null
  }
}

foreach ($name in 'backend', 'frontend') {
  $pidFile = Join-Path $runDir "$name.pid"
  if (Test-Path -LiteralPath $pidFile) {
    $pidText = (Get-Content -LiteralPath $pidFile -Raw).Trim()
    $pid = 0
    if ([int]::TryParse($pidText, [ref]$pid)) {
      Stop-ProcessTree -ProcessId $pid
    }
    Remove-Item -LiteralPath $pidFile -Force
  }
}

$portOwners = @(8080, 8081) | ForEach-Object {
  Get-NetTCPConnection -LocalPort $_ -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess
} | Where-Object { $_ -and $_ -gt 0 } | Sort-Object -Unique

foreach ($pid in $portOwners) {
  Stop-ProcessTree -ProcessId ([int]$pid)
}

$projectProcesses = Get-CimInstance Win32_Process | Where-Object {
  $_.CommandLine -and
  (
    (
      $_.CommandLine -match [regex]::Escape($rootPath) -and
      (
        $_.CommandLine -match 'backend\\pom\.xml' -or
        $_.CommandLine -match 'spring-boot:run' -or
        $_.CommandLine -match '--prefix frontend' -or
        $_.CommandLine -match 'vite'
      )
    ) -or
    $_.CommandLine -match 'mvn\s+-f\s+backend\\pom\.xml\s+spring-boot:run' -or
    $_.CommandLine -match 'npm\s+--prefix\s+frontend\s+run\s+dev' -or
    $_.CommandLine -match 'vite\s+--host\s+127\.0\.0\.1'
  )
}

foreach ($process in $projectProcesses) {
  Stop-ProcessTree -ProcessId ([int]$process.ProcessId)
}

Get-Process cmd -ErrorAction SilentlyContinue | Where-Object {
  $_.MainWindowTitle -like '*校园招聘系统*' -or
  $_.MainWindowTitle -eq 'npm'
} | ForEach-Object {
  Stop-ProcessTree -ProcessId ([int]$_.Id)
}

Write-Output 'stopped'
