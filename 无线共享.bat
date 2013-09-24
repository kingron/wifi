@echo off
@title WIFI无线共享工具

REM 版权所有，Kingron<kingron@163.com>

set help=0
if "%1"=="/?" set help=1
if "%1"=="help" set help=1
if "%1"=="-help" set help=1
if %help% equ 1 (
  echo WIFI无线共享工具 v1.2
  echo 用法
  echo    %~n0 [create ^| start ^| stop ^| view ^| password ^| help]
  exit /b 0
)

net session >nul 2>&1
if not "%errorLevel%" == "0" (
  echo 本工具需要管理员权限，将自动切换到管理员权限，如果弹出用户权限控制对话框，
  echo 请点击【是】按钮以继续运行，否则不能正常工作。
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
echo WIFI无线共享工具 v1.2
echo 创建、启动、停止笔记本的虚拟WIFI热点，共享上网。
echo 本工具需要WIFI网卡支持虚拟AP才能使用，目前大部分WIFI芯片都支持。
echo 本工具无需安装任何第三方软件，也不占用任何系统资源，完全绿色环保。
echo.
echo ┏━━━━━━━━━━┓
echo ┃ 无线共享工具v1.2   ┃
echo ┣━━━━━━━━━━┫
echo ┃ 1. 创建虚拟WIFI    ┃
echo ┃ 2. 启动虚拟WIFI    ┃
echo ┃ 3. 停止虚拟WIFI    ┃
echo ┃ 4. 查看WIFI连接    ┃
echo ┃ 5. 更改WIFI密码    ┃
echo ┃ 6. 共享WIFI连接    ┃
echo ┃ 7. 退出            ┃
echo ┗━━━━━━━━━━┛
echo.
set /p mid=请选择 1-7 的命令，按Enter继续：
if "%mid%"=="1" goto create
if "%mid%"=="2" goto start
if "%mid%"=="3" goto stop
if "%mid%"=="4" goto view
if "%mid%"=="5" goto password
if "%mid%"=="6" goto share
if "%mid%"=="7" goto end
echo 错误：选择的命令无效，请重试。
goto menu

:create
echo.
echo 注意：
echo 创建虚拟WIFI只要运行一次就可以了，无需多次运行。
echo 如果你要重新初始化WIFI，如更改WIFI的SSID和密码，那可以重新运行一次。
echo.

REM if you want to use this for other language, you should change below tags.
REM CP 936 = Chinese, 437 = English
echo 检查无线网卡是否支持虚拟WIFI热点...
set supported=0
netsh wlan show drive | find "支持的承载网络" | find "是"
if %errorlevel%==0 set supported=1
netsh wlan show drive | find "Hosted network supported" | find "Yes"
if %errorlevel%==0 set supported=1
if %supported% equ 1 (
  echo 恭喜！你的无线网卡支持虚拟WIFI热点模式！
  echo 请根据后续指令完成无线WIFI的配置。
) else (
  echo 很遗憾，你的无线网卡不支持虚拟WIFI热点模式！
  exit /b 1
)

if "%_name%"=="" set _name=wlan
set /p _name=请输入WIFI热点的名字（默认: %_name%）：
set /p _password=请输入WIFI热点的密码（必需，密码长度为 8~63 字符）：
netsh wlan set hostednetwork mode=allow ssid=%_name% key=%_password%
if "%errorlevel%"=="0" echo 配置WIFI成功。
netsh wlan start hostednetwork
if "%errorlevel%"=="0" (
  echo 启动WIFI成功，使用愉快！
  echo 如果需要共享给手机或者其他人上网，请重新运行并选择共享WIFI连接。
) else (
  echo 错误：启动WIFI热点失败。
)
goto end

:start
netsh wlan start hostednetwork
if "%errorlevel%"=="0" (
  echo 启动WIFI成功，使用愉快！
) else (
  echo 错误：启动WIFI热点失败。
)
goto end

:stop
netsh wlan stop hostednetwork
goto end

:password
set /p _password=请输入WIFI热点的密码（必需，密码长度为 8~63 字符）：
netsh wlan set hostednetwork key=%_password% > nul
if "%errorlevel%"=="0" (
  echo 更改WIFI密码成功！
) else (
  echo 错误：更改密码失败。
  echo 请检查输入的密码并重试，密码为 8-63 字符。
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
pause