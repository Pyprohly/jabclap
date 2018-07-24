0</* :
@echo off
setlocal

set "trials=10"

REM __ hello.bat __
echo hello.bat

for /f "delims=" %%I in (' cscript.exe /nologo /e:jscript "%~f0" ') do (
	set "start_time=%%~I"
)
set "start_time=%start_time:~-9%"

for /l %%_ in (1 1 %trials%) do (
	call hello.bat "Hello World" /fg f /bg 6
)

for /f "delims=" %%I in (' cscript.exe /nologo /e:jscript "%~f0" ') do (
	set "end_time=%%~I"
)
set "end_time=%end_time:~-9%"

set /a time_diff=end_time - start_time
echo %time_diff%
REM ^^ hello.bat ^^

echo(
REM __ hello2.bat __
echo hello2.bat

for /f "delims=" %%I in (' jTimestamp.bat -f "{ums}" ') do (
	set "start_time=%%~I"
)
set "start_time=%start_time:~-9%"

for /l %%_ in (1 1 %trials%) do (
	call hello2.bat "Hello World" /fg f /bg 6
)

for /f "delims=" %%I in (' jTimestamp.bat -f "{ums}" ') do (
	set "end_time=%%~I"
)
set "end_time=%end_time:~-9%"

set /a time_diff=end_time - start_time
echo %time_diff%
REM ^^ hello2.bat ^^

exit /b
*/0

WScript.Echo((new Date).getTime())
