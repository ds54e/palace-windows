@echo off
setlocal
rem Repository-local compiler packages; no persistent environment changes.
set "PW_ROOT=%~dp0.."
set "PW_VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%PW_VSWHERE%" exit /b 2
for /f "usebackq delims=" %%i in (`"%PW_VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "PW_VS=%%i"
if not defined PW_VS exit /b 2
call "%PW_VS%\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b %errorlevel%
set "PW_INTEL=%PW_ROOT%\.work\deps\intel"
set "PATH=%PW_INTEL%\Library\bin;%PW_VS%\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%"
set "INCLUDE=%PW_INTEL%\opt\compiler\include\intel64;%INCLUDE%"
set "LIB=%PW_INTEL%\Library\lib;%LIB%"
rem CALL returns control even when the requested command is another batch file.
call %*
exit /b %errorlevel%
