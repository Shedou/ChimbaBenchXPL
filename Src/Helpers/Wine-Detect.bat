@echo off
reg query "HKCU\Software\Wine" >nul 2>&1 && echo WINE