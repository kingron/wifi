@echo off
@title WIFI Sharing Tools

REM WIFI Sharing Tools for Windows
REM Copyright Kingron<kingron@163.com>
REM Only test for Windows 7(English version, Simplified Chinese version)
REM This tools can create virtual WIFI access point, start and stop virtual WLAN,
REM The virtual WLAN AP can be used for any mobile device, smart phone and etc.
REM You WIFI adapter must support Ad-Hoc mode(For intel WLAN chipset, it means
REM Intel MyWiFi), most of the wifi chipset support Ad-Hoc mode now.
REM You should see a "Microsoft Virtual WiFi Miniport Adapter" from "control panel\
REM network and internet\network connections"
REM !WARNNING!
REM    You MUST run this batch with administrator permissions

set help=0
if "%1"=="/?" set help=1
if "%1"=="help" set help=1
if "%1"=="-help" set help=1
if %help% equ 1 (
  echo WIFI sharing tools v1.1
  echo Usage
  echo    %~n0 [create ^| start ^| stop ^| view ^| password ^| help]
  exit /b 0
)

net session >nul 2>&1
if not "%errorLevel%" == "0" (
  echo Oops: This tools must run with administrator permissions!
  echo it will popup the UAC dialog, please click [Yes] to continue.
  echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
  echo UAC.ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\getadmin.vbs"

  "%temp%\getadmin.vbs"
  exit /b 2
)

if "%1"=="create" goto create
if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="view" goto view
if "%1"=="password" goto password
if "%1"=="share" goto share

:menu
echo.
echo ┏━━━━━━━━━━━━━┓
echo ┃     WIFI Tools Menu      ┃
echo ┣━━━━━━━━━━━━━┫
echo ┃ 1. Create virtual WLAN   ┃
echo ┃ 2. Start virtual WLAN    ┃
echo ┃ 3. Stop virtual WLAN     ┃
echo ┃ 4. View WLAN connections ┃
echo ┃ 5. Change WLAN password  ┃
echo ┃ 6. Share Connection(ICS) ┃
echo ┃ 7. Exit                  ┃
echo ┗━━━━━━━━━━━━━┛
echo.
set /p mid=Please select the number and press ^<ENTER^>:
if "%mid%"=="1" goto create
if "%mid%"=="2" goto start
if "%mid%"=="3" goto stop
if "%mid%"=="4" goto view
if "%mid%"=="5" goto password
if "%mid%"=="6" goto share
if "%mid%"=="7" goto end
echo Error: Invalid command, please try again.
goto menu

:create
echo.
echo NOTE:
echo The "create virtual WLAN" command only run once if success, you needn't run it
echo again unless you want to change the SSID or password!
echo.

REM if you want to use this for other language, you should change below tags.
REM CP 936 = Chinese, 437 = English
echo Check your WIFI adapter...
set supported=0
netsh wlan show drive | find "支持的承载网络" | find "是"
if %errorlevel%==0 set supported=1
netsh wlan show drive | find "Hosted network supported" | find "Yes"
if %errorlevel%==0 set supported=1
if %supported% equ 1 (
  echo Congratulation! You WIFI adapter support Ad-Hoc mode.
  echo Please follow step to finish the setup.
) else (
  echo Oops! You WIFI adapter can't support Ad-Hoc mode^(hostednetwork^).
  exit /b 1
)

if "%_name%"=="" set _name=wlan
set /p _name=Please input the virtual AP name(default: %_name%):
set /p _password=Please input the password^(required, length: 8~63^):
netsh wlan set hostednetwork mode=allow ssid=%_name% key=%_password%
if "%errorlevel%"=="0" (
  echo Setup the WLAN success.
)
netsh wlan start hostednetwork
if "%errorlevel%"=="0" (
  echo Startup WLAN success, enjoy it!
  echo Please goto control panel, network connections, share the internet connection
  echo to virtual WIFI adapter.
) else (
  echo Error: Started WLAN failure.
)
goto end

:start
netsh wlan start hostednetwork
if "%errorlevel%"=="0" (
  echo Startup WLAN success, enjoy it!
) else (
  echo Error: Started WLAN failure.
)
goto end

:stop
netsh wlan stop hostednetwork
goto end

:password
set /p _password=Please input the password^(required, length: 8~63^):
netsh wlan set hostednetwork key=%_password% > nul
if "%errorlevel%"=="0" (
  echo Change WLAN password success!
) else (
  echo Error: Change WLAN password failure.
  echo Please check inputed password and try again.
  goto menu
)
goto end

:view
netsh wlan show hostednetwork
goto end

:share
cscript /nologo %~dp0\share.vbs
goto end

:end
set _name=
set _password=
set mid=
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
