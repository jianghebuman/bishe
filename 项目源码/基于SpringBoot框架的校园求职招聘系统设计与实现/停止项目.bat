@echo off
chcp 936 >nul
setlocal EnableExtensions

set "ROOT=%~dp0"
set "ROOT_ARG=%~dp0."

echo ========================================
echo   校园求职招聘系统 - 停止后台服务
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\stop-project.ps1" -Root "%ROOT_ARG%"

echo.
echo [完成] 后台服务已停止。
echo.
pause
