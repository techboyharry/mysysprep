@echo off
net session >nul 2>&1
if not %errorLevel% == 0 if not "%1"=="elevated" (
powershell start -verb runas '%0' elevated & exit /b
)
cd /d %~dp0\..
powershell -exec bypass -file modules\deploy_pkgs\main.ps1
pause
