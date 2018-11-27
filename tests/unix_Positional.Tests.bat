@echo off
setlocal DisableDelayedExpansion

if not defined parser (
	set "parser=%~dp0\..\src\parser-unix.js"
)

set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_CASE_SENSITIVE=1"
set "JABCLAP_FLAG_BUNDLING=1"
set "JABCLAP_KEY_INDICATOR=-"
set "JABCLAP_PAIR_DELIMITER== "

goto :main

:arg_parse OutVar ArgsVar
setlocal DisableDelayedExpansion
	set "_f0=%~f0"
	setlocal EnableDelayedExpansion
	set "_args=!%~2!"
goto 2>nul & (
	endlocal
	for /f "tokens=1 delims==" %%I in (' 2^>nul set "%~1[" ') do set "%%I="
	setlocal DisableDelayedExpansion
	set "_f0=%_f0%"
	set "_args=%_args%"
	setlocal EnableDelayedExpansion
	for /f "delims=" %%I in (
		'cscript.exe /nologo /e:jscript "!parser!" // !_args!'
	) do (
		endlocal & endlocal
		set "%~1%%I"
		setlocal & setlocal
	)
	endlocal
)

:start_test
	set /a test_num+=1
	set /a fail=0
goto :eof

:end_test
setlocal
	if %fail% equ 0 (
		set/p=%BS%    [+] <nul
	) else (
		set/p=%BS%    [-] ^(%test_num%^) <nul
	)
	echo(%It%
endlocal
goto :eof


:main
for /f %%G in (' "prompt $H & for %%_ in (1) do rem" ') do set "BS=%%G"
set /a test_num=0

setlocal
set "args=arg1 arg2 arg3 arg4 arg5 arg6 arg7"
call :arg_parse arg args
endlocal

:test 1
set "It=correctly stores positional arguments"
call :start_test
if not "%arg[1]%"=="arg1" (
	set /a fail+=1
)
if not "%arg[2]%"=="arg2" (
	set /a fail+=1
)
if not "%arg[3]%"=="arg3" (
	set /a fail+=1
)
if not "%arg[7]%"=="arg7" (
	set /a fail+=1
)
call :end_test

:test 2
set "It=leaves the eighth variable undefined when seven positional arguments are given"
call :start_test
if not "%arg[8]%"=="" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=arg1 "" " " "" arg2"
call :arg_parse arg args
endlocal

:test 3
set "It=correctly stores empty positional arguments"
call :start_test
if not "%arg[1]%"=="arg1" (
	set /a fail+=1
)
if not "%arg[2]%"=="" (
	set /a fail+=1
)
if not "%arg[3]%"==" " (
	set /a fail+=1
)
if not "%arg[4]%"=="" (
	set /a fail+=1
)
if not "%arg[5]%"=="arg2" (
	set /a fail+=1
)
if not "%arg[6]%"=="" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-o0 arg1 -o1 arg2 -o2 arg3 -o3"
call :arg_parse arg args
endlocal

:test 4
set "It=correctly stores positional arguments when interspersed with options"
call :start_test
if not "%arg[1]%"=="arg1" (
	set /a fail+=1
)
if not "%arg[2]%"=="arg2" (
	set /a fail+=1
)
if not "%arg[3]%"=="arg3" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=arg1 "" -key=" v a l " arg2 -k" "ey=val arg3 -ke"y 2"= arg4"
call :arg_parse arg args
endlocal

:test 5
set "It=correctly stores positional arguments when interspersed with key-value arguments"
call :start_test
if not "%arg[1]%"=="arg1" (
	set /a fail+=1
)
if not "%arg[3]%"=="arg2" (
	set /a fail+=1
)
if not "%arg[4]%"=="arg3" (
	set /a fail+=1
)
if not "%arg[5]%"=="arg4" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a -b -c"
call :arg_parse arg args
endlocal

:test 6
set "It=correctly stores the count of the positional arguments when no positional arguments are specified"
call :start_test
if %arg[#p]% neq 0 (
	set /a fail+=1
)
if %arg[#]% neq 0 (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a a -b b -c c -d"
call :arg_parse arg args
endlocal

:test 7
set "It=correctly stores the count of positionals with interspersed named arguments"
call :start_test
if %arg[#p]% neq 3 (
	set /a fail+=1
)
if %arg[#]% neq 3 (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a a -b -- b -c c --d"
call :arg_parse arg args
endlocal

:test 8
set "It=treats arguments after the end of options marker as positional"
call :start_test
if not "%arg[1]%"=="a" (
	set /a fail+=1
)
if not "%arg[2]%"=="b" (
	set /a fail+=1
)
if not "%arg[3]%"=="-c" (
	set /a fail+=1
)
if not "%arg[4]%"=="c" (
	set /a fail+=1
)
if not "%arg[5]%"=="--d" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_KEY_INDICATOR= "

setlocal
set "args=a -o " o" " -o""
call :arg_parse arg args
endlocal

:test 9
set "It=treats all named arguments as positional if the indicator is a space"
call :start_test
if not "%arg[1]%"=="a" (
	set /a fail+=1
)
if not "%arg[2]%"=="-o" (
	set /a fail+=1
)
if not "%arg[3]%"==" o" (
	set /a fail+=1
)
if not "%arg[4]%"==" -o" (
	set /a fail+=1
)
call :end_test
