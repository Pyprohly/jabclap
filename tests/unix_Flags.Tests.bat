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
set "args=-o"
call :arg_parse arg args
endlocal

:test 1
set "It=records a used option"
call :start_test
if not "%arg['o']%"=="1" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_FLAG_BUNDLING=0"

setlocal
set "args=-option1 -option2"
call :arg_parse arg args
endlocal

:test 2
set "It=respects the flag bundling option when it is disabled"
call :start_test
if not "%arg['option1']%"=="1" (
	set /a fail+=1
)
if not "%arg['option2']%"=="1" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_FLAG_BUNDLING=1"

setlocal
set "args=-abc"
call :arg_parse arg args
endlocal

:test 3
set "It=unbundles flags"
call :start_test
if not defined arg['a'] (
	set /a fail+=1
)
if not defined arg['b'] (
	set /a fail+=1
)
if not defined arg['c'] (
	set /a fail+=1
)
if defined arg['abc'] (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-- -abc"
call :arg_parse arg args
endlocal

:test 4
set "It=doesn't unbundle flags after the end of options marker"
call :start_test
if defined arg['a'] (
	set /a fail+=1
)
if defined arg['b'] (
	set /a fail+=1
)
if defined arg['c'] (
	set /a fail+=1
)
if defined arg['abc'] (
	set /a fail+=1
)
if not defined arg[1] (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a a -b b -c c -d"
call :arg_parse arg args
endlocal

:test 5
set "It=records switches interspersed with positional arguments"
call :start_test
if not defined arg['a'] (
	set /a fail+=1
)
if not defined arg['b'] (
	set /a fail+=1
)
if not defined arg['c'] (
	set /a fail+=1
)
if not defined arg['d'] (
	set /a fail+=1
)
call :end_test

:test 6
set "It=stores '1' in the arg[?'key'] variable"
call :start_test
if not "%arg[?'a']%"=="1" (
	set /a fail+=1
)
if not "%arg[?'b']%"=="1" (
	set /a fail+=1
)
if not "%arg[?'c']%"=="1" (
	set /a fail+=1
)
if not "%arg[?'d']%"=="1" (
	set /a fail+=1
)
if not "%arg[?'a']%"=="1" (
	set /a fail+=1
)
call :end_test
