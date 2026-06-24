@echo off
chcp 936 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "ROOT_ARG=%~dp0."
set "BACKEND_POM=%ROOT%backend\pom.xml"
set "FRONTEND_DIR=%ROOT%frontend"
set "FRONTEND_PACKAGE=%FRONTEND_DIR%\package.json"
set "FRONTEND_NODE_MODULES=%FRONTEND_DIR%\node_modules"
set "SCRIPT_DIR=%ROOT%scripts"
set "LOG_DIR=%ROOT%logs"
set "RUN_DIR=%ROOT%.run"
set "BACKEND_URL=http://localhost:8081/api"
set "FRONTEND_URL=http://127.0.0.1:8080/"
set "CHECK_ONLY=0"
set "OPEN_BROWSER=1"
set "NO_PAUSE=0"
set "AUTO_CLOSE=1"

:parseArgs
if "%~1"=="" goto :afterParseArgs
if /I "%~1"=="--check" set "CHECK_ONLY=1"
if /I "%~1"=="--no-browser" set "OPEN_BROWSER=0"
if /I "%~1"=="--no-pause" set "NO_PAUSE=1"
if /I "%~1"=="--pause" set "AUTO_CLOSE=0"
shift
goto :parseArgs
:afterParseArgs

cd /d "%ROOT%" >nul 2>nul
if errorlevel 1 (
  echo [错误] 无法进入项目目录：%ROOT%
  goto :fail
)

title 校园求职招聘系统 - 通用启动脚本

echo ========================================
echo   校园求职招聘系统 - 通用启动脚本
echo ========================================
echo.

echo [1/4] 正在检查项目目录...
if not exist "%BACKEND_POM%" (
  echo [错误] 未找到后端配置文件：backend\pom.xml
  echo        请把本脚本放在项目根目录后再运行。
  goto :fail
)
if not exist "%FRONTEND_PACKAGE%" (
  echo [错误] 未找到前端配置文件：frontend\package.json
  echo        请把本脚本放在项目根目录后再运行。
  goto :fail
)
if not exist "%SCRIPT_DIR%\start-service.ps1" (
  echo [错误] 未找到后台启动脚本：scripts\start-service.ps1
  goto :fail
)
echo [正常] 项目目录检查通过。
echo.

echo [2/4] 正在检查运行环境...
set "MISSING="
call :checkCommand "Java" "java" "请安装 JDK 8 或更高版本，并配置 JAVA_HOME / Path。"
call :checkCommand "Maven" "mvn" "请安装 Maven 3.x，并把 Maven 的 bin 目录加入 Path。"
call :checkCommand "Node.js" "node" "请安装 Node.js LTS 版本，并勾选自动配置 Path。"
call :checkCommand "npm" "npm" "npm 通常随 Node.js 一起安装；如缺失请重新安装 Node.js。"

if defined MISSING (
  echo.
  echo [错误] 当前电脑缺少必要环境：!MISSING!
  echo        请先安装并配置以上环境，然后重新双击运行本脚本。
  goto :fail
)
echo [正常] Java / Maven / Node.js / npm 均已检测到。
echo.

echo [3/4] 正在检查前端依赖...
if not exist "%FRONTEND_NODE_MODULES%" (
  echo [提示] 未检测到 frontend\node_modules，正在执行 npm install。
  echo        首次安装可能需要几分钟，请不要关闭窗口。
  pushd "%FRONTEND_DIR%" >nul
  call npm install
  if errorlevel 1 (
    popd >nul
    echo.
    echo [错误] 前端依赖安装失败。
    echo        请检查网络、npm 镜像源或 package.json 配置后重试。
    goto :fail
  )
  popd >nul
  echo [正常] 前端依赖安装完成。
) else (
  echo [正常] 已检测到 frontend\node_modules，跳过 npm install。
)
echo.

if "%CHECK_ONLY%"=="1" (
  echo [检查完成] 环境和项目结构均正常，未执行启动。
  exit /b 0
)

echo [4/4] 正在启动项目...
echo.
echo 后端地址：%BACKEND_URL%
echo 前端地址：%FRONTEND_URL%
echo.
echo [提示] 请确认本机 MySQL 数据库已启动，并且后端配置中的数据库账号密码正确。
echo        如果后端窗口提示数据库连接失败，请先启动 MySQL 或修改配置后重试。
echo.

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul
if not exist "%RUN_DIR%" mkdir "%RUN_DIR%" >nul 2>nul

call :isPortListening 8081
if errorlevel 1 (
  echo [启动] 后端正在后台启动，日志：logs\backend.log
  call :startHiddenService backend "后端"
  if errorlevel 1 goto :fail
) else (
  echo [提示] 后端端口 8081 已在监听，跳过后端重复启动。
)

call :isPortListening 8080
if errorlevel 1 (
  echo [启动] 前端正在后台启动，日志：logs\frontend.log
  call :startHiddenService frontend "前端"
  if errorlevel 1 goto :fail
) else (
  echo [提示] 前端端口 8080 已在监听，跳过前端重复启动。
)

echo 已在后台启动后端和前端。
echo 正在等待服务端口就绪，请稍候...
call :waitForPort 8081 60 "后端"
if errorlevel 1 (
  echo [提示] 后端端口 8081 暂未就绪，请查看 logs\backend.log。
)
call :waitForPort 8080 60 "前端"
if errorlevel 1 (
  echo [提示] 前端端口 8080 暂未就绪，请查看 logs\frontend.log。
)
if "%OPEN_BROWSER%"=="1" start "" "%FRONTEND_URL%"

echo.
echo 如果浏览器暂时打不开，请再等几秒刷新：
echo %FRONTEND_URL%
echo.
echo 后台日志目录：%LOG_DIR%
echo 如需停止后台服务，请运行：停止项目.bat
echo.
if "%NO_PAUSE%"=="1" exit /b 0
if "%AUTO_CLOSE%"=="1" (
  echo 启动成功，本窗口 3 秒后自动关闭。
  timeout /t 3 /nobreak >nul
  exit /b 0
)
pause
exit /b 0

:checkCommand
set "DISPLAY_NAME=%~1"
set "COMMAND_NAME=%~2"
set "HELP_TEXT=%~3"
where "%COMMAND_NAME%" >nul 2>nul
if errorlevel 1 (
  echo [缺失] %DISPLAY_NAME%：未找到 %COMMAND_NAME% 命令。
  echo        %HELP_TEXT%
  set "MISSING=!MISSING! %DISPLAY_NAME%"
) else (
  for /f "usebackq delims=" %%v in (`%COMMAND_NAME% --version 2^>nul`) do (
    echo [正常] %DISPLAY_NAME%：%%v
    goto :eof
  )
  echo [正常] %DISPLAY_NAME%：已安装
)
goto :eof

:startHiddenService
set "SERVICE_KEY=%~1"
set "SERVICE_NAME=%~2"
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%\start-service.ps1" -Root "%ROOT_ARG%" -Service "%SERVICE_KEY%" >nul
if errorlevel 1 (
  echo [错误] %SERVICE_NAME%后台启动失败，请查看 logs\%SERVICE_KEY%.log。
  exit /b 1
)
exit /b 0

:waitForPort
set "PORT=%~1"
set "WAIT_SECONDS=%~2"
set "SERVICE_NAME=%~3"
set /a "WAITED=0"
:waitForPortLoop
call :isPortListening %PORT%
if not errorlevel 1 (
  echo [正常] %SERVICE_NAME%端口 %PORT% 已就绪。
  exit /b 0
)
set /a "WAITED+=1"
if !WAITED! GEQ %WAIT_SECONDS% exit /b 1
powershell -NoProfile -Command "Start-Sleep -Seconds 1" >nul 2>nul
goto :waitForPortLoop
exit /b 1

:isPortListening
set "CHECK_PORT=%~1"
netstat -ano | findstr /R /C:":%CHECK_PORT% .*LISTENING" >nul 2>nul
if errorlevel 1 exit /b 1
exit /b 0

:fail
echo.
echo 启动未完成。请根据上面的中文提示处理后重新运行。
echo.
if "%NO_PAUSE%"=="1" exit /b 1
pause
exit /b 1
