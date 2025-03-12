@echo off
title MPS Traffic Generator - By Landon (v0.1.0)
mode con: cols=80 lines=25
color 0A

:: Display Author & Disclaimer
cls
echo ======================================================
echo      ███╗   ███╗██████╗ ███████╗
echo      ████╗ ████║██╔══██╗██╔════╝
echo      ██╔████╔██║██████╔╝███████╗
echo      ██║╚██╔╝██║██╔═══╝ ╚════██║
echo      ██║ ╚═╝ ██║██║     ███████║
echo      ╚═╝     ╚═╝╚═╝     ╚══════╝
echo ======================================================
echo     By Landon - MPS v0.1.0 - For Educational Purposes Only
echo ======================================================
echo WARNING: This script generates real network traffic.
echo Use only in a controlled environment with proper authorization.
echo Targeting unauthorized systems is illegal and unethical.
timeout /t 5 >nul

:: Main Menu
:menu
cls
color 0A
echo =====================================
echo      MPS Traffic Generator     
echo =====================================
echo [1] Generate Large Traffic (IPs or Websites)
echo [2] Exit
echo =====================================
:get_choice
set /p choice=Enter your choice: 
if "%choice%"=="1" goto target_input
if "%choice%"=="2" exit
echo Invalid choice! Try again.
goto get_choice

:: Ask for Target (IP or Website)
:target_input
cls
echo =====================================
echo    ENTER TARGET     
echo =====================================
echo Enter an IP address or website to generate traffic:
echo Example: 192.168.1.1 or http://example.com
set /p target=Target: 
if "%target%"=="" (
    echo Target cannot be empty! Try again.
    timeout /t 2 >nul
    goto target_input
)

:: Check if target is an IP address
echo %target% | findstr /r "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if %errorlevel%==0 (
    set is_ip=1
) else (
    set is_ip=0
)

:: Ask for Protocol (if target is an IP)
if %is_ip%==1 (
    :protocol_input
    cls
    echo =====================================
    echo    ENTER PROTOCOL     
    echo =====================================
    echo [1] TCP
    echo [2] UDP
    set /p protocol=Enter protocol (1-2): 
    if "%protocol%"=="1" set protocol=TCP
    if "%protocol%"=="2" set protocol=UDP
    if not "%protocol%"=="TCP" if not "%protocol%"=="UDP" (
        echo Invalid protocol! Try again.
        timeout /t 2 >nul
        goto protocol_input
    )
)

:: Ask for Number of Packets/Requests
:packet_input
cls
echo =====================================
echo    ENTER NUMBER OF PACKETS/REQUESTS     
echo =====================================
echo Enter the number of packets/requests to send (1-1000):
set /p packets=Packets/Requests: 
if %packets% LSS 1 (
    echo Minimum packets/requests is 1. Try again.
    timeout /t 2 >nul
    goto packet_input
)
if %packets% GTR 1000 (
    echo Maximum packets/requests is 1000. Try again.
    timeout /t 2 >nul
    goto packet_input
)

:: Confirm target before starting
cls
echo =====================================
echo    WARNING     
echo You are about to generate traffic to: %target%
echo Packets/Requests to send: %packets%
if %is_ip%==1 (
    echo Protocol: %protocol%
)
echo This will send a high volume of packets/requests.
echo Are you sure you want to proceed?
echo =====================================
echo [1] Confirm & Start Traffic Generation
echo [2] Enter a Different Target
:get_confirm
set /p confirm=Enter choice: 
if "%confirm%"=="1" goto start_traffic
if "%confirm%"=="2" goto target_input
echo Invalid choice! Try again.
goto get_confirm

:: Start Traffic Generation
:start_traffic
cls
echo Starting traffic generation to %target%...
timeout /t 2 >nul

:: Initialize counters
set /a packets_sent=0
set /a total_bytes=0

:: Main traffic generation loop
:traffic
cls
color 04
echo MPS Traffic Generator - By Landon (v0.1.0)
echo =========================
echo Target: %target%
if %is_ip%==1 (
    echo Protocol: %protocol%
)
echo =========================
echo Packets/Requests Sent: %packets_sent%
set /a data_sent_mb=%total_bytes% / 1048576
set /a data_sent_gb=%data_sent_mb% / 1024
echo Data Sent: %data_sent_mb% MB (%data_sent_gb% GB)
echo =========================

:: Send traffic based on target type
if %is_ip%==1 (
    if "%protocol%"=="TCP" (
        powershell -Command "$client = New-Object System.Net.Sockets.TcpClient('%target%', 80); $stream = $client.GetStream(); $buffer = New-Object Byte[] 1048576; $stream.Write($buffer, 0, 1048576); $stream.Close(); $client.Close();"
    ) else if "%protocol%"=="UDP" (
        powershell -Command "$client = New-Object System.Net.Sockets.UdpClient('%target%', 80); $buffer = New-Object Byte[] 1048576; $client.Send($buffer, 1048576); $client.Close();"
    )
) else (
    powershell -Command "$webRequest = [System.Net.WebRequest]::Create('%target%'); $webRequest.Method = 'POST'; $webRequest.ContentLength = 1048576; $stream = $webRequest.GetRequestStream(); $buffer = New-Object Byte[] 1048576; $stream.Write($buffer, 0, 1048576); $stream.Close(); $response = $webRequest.GetResponse(); $response.Close();"
)

:: Update counters
set /a packets_sent+=1
set /a total_bytes+=1048576  :: 1 MB per packet/request

:: Wait for 1 second before sending the next packet/request
timeout /t 1 >nul
if %packets_sent% LSS %packets% goto traffic

echo Traffic generation complete.
pause
goto menu
