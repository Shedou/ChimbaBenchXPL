@echo off

cd /d "%~dp0"

:: echo Collecting system information (CPU name, GPU name, OS name). Please wait...

reg query "HKCU\Software\Wine" >nul 2>&1
if %errorlevel% equ 0 (
    echo WINE
) else (
    echo REAL
)

for /f "delims=" %%a in ('ver') do set "win_ver=%%a"
echo %win_ver%

for /f "tokens=2,*" %%a in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v ProcessorNameString ^| find "REG_SZ"') do echo %%b

for /f "delims=" %%i in ('Windows-GPU-Info-Alt-Drv.exe') do (
    echo %%i
)

