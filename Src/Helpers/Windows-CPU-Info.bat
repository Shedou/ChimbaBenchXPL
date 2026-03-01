@echo off
for /f "tokens=2,*" %%a in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v ProcessorNameString ^| find "REG_SZ"') do echo %%b