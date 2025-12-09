@ECHO OFF
CLS
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/c cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
call :Resume
goto %current%
goto :eof

:one
CLS
ECHO.
ECHO Welcome to Morgan's AIO Windows Repair Command Toolkit
ECHO.
ECHO Please choose an option:
ECHO 1. Run Initial Scan
ECHO 2. Cleanup Image
ECHO 3. Check Disk
ECHO 4. Repair WMI Repository
ECHO 5. Automated Full Repair
ECHO 6. Exit
ECHO.

CHOICE /N /C:123456 /M "Enter your choice (1,2,3,4, or 5): "

IF ERRORLEVEL 6 GOTO EXIT_PROGRAM
IF ERRORLEVEL 5 GOTO two
IF ERRORLEVEL 4 GOTO PROGRAM_D
IF ERRORLEVEL 3 GOTO MENU2
IF ERRORLEVEL 2 GOTO PROGRAM_B
IF ERRORLEVEL 1 GOTO PROGRAM_A
goto :eof

:two
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f
echo three >%~dp0current.txt
echo -- Step one --
ECHO Running initial scan...
sfc /scannow
GOTO REBOOT_NOW
goto :eof

:three
echo four >%~dp0current.txt
echo -- Step two --
ECHO Attempting to cleanup image...
dism /Online /Cleanup-Image /RestoreHealth
ECHO Cleanup finished... Attempting scan and repair...
sfc /scannow
GOTO REBOOT_NOW
goto :eof

:four
echo five >%~dp0current.txt
echo -- Step three --
ECHO Checking Disk...
chkdsk /f
GOTO REBOOT_NOW
goto :eof

:five
echo six >%~dp0current.txt
echo -- Step four --
ECHO Attempting to repair WMI repository..
winmgmt /salvagerepository
pause
GOTO REBOOT_NOW
goto :eof

:six
echo -- Step five --
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /f
del %~dp0current.txt
pause
goto :one

:PROGRAM_A
CLS
ECHO Running initial scan...
sfc /scannow
ECHO Process complete... A Reboot is recommended...
PAUSE
GOTO REBOOT_PROGRAM

:PROGRAM_B
CLS
ECHO Attempting to cleanup image...
dism /Online /Cleanup-Image /RestoreHealth
ECHO Cleanup finished... Attempting scan and repair...
sfc /scannow
ECHO Process complete... A reboot is recommended...
PAUSE
GOTO REBOOT_PROGRAM

:MENU2
CLS
ECHO.
ECHO Please choose an option:
ECHO 1. Check disk
ECHO 2. Check disk and recover data (takes a long time)
ECHO 3. Return to the menu
ECHO.

CHOICE /N /C:123 /M "Enter your choice (1,2 or 3): "

IF ERRORLEVEL 3 GOTO one
IF ERRORLEVEL 2 GOTO PROGRAM_C2
IF ERRORLEVEL 1 GOTO PROGRAM_C1

:PROGRAM_C1
ECHO Checking Disk...
chkdsk /f
PAUSE
GOTO REBOOT_PROGRAM

:PROGRAM_C2
ECHO Checking Disk...
chkdsk /r
PAUSE
GOTO REBOOT_PROGRAM

:PROGRAM_D
CLS
ECHO Attempting to repair WMI repository..
winmgmt /salvagerepository
PAUSE
GOTO REBOOT_PROGRAM

:REBOOT_PROGRAM
choice /m "Would you like o reboot now?"
if %errorlevel% equ 1 goto REBOOT_NOW
if %errorlevel% equ 2 goto one
GOTO MENU

:REBOOT_NOW
ECHO Rebooting in 5...
Rem timeout /t 5 >nul
shutdown /r /t 0

:EXIT_PROGRAM
ECHO Exiting...
PAUSE
EXIT

:resume
if exist %~dp0current.txt (
    set /p current=<%~dp0current.txt
) else (
    set current=one
	goto one
)