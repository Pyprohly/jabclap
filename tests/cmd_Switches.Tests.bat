@echo off
setlocal DisableDelayedExpansion

if not defined parser (
	set "parser=%~dp0\..\src\parser-cmd.js"
)

set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_CASE_SENSITIVE=0"
set "JABCLAP_KEY_INDICATOR=/"
set "JABCLAP_PAIR_DELIMITER=:="

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

set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_KEY_INDICATOR=/"
set "JABCLAP_PAIR_DELIMITER=:="

setlocal
set "args=/s"
call :arg_parse arg args
endlocal

:test 1
set "It=records a used switch"
call :start_test
if not "%arg['s']%"=="1" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=/switch"
call :arg_parse arg args
endlocal

:test 2
set "It=records a used switch that is more than one character long"
call :start_test
if not "%arg['switch']%"=="1" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=/s /s"
call :arg_parse arg args
endlocal

:test 3
set "It=accepts duplicate switches"
call :start_test
if not defined arg['s'] (
	set /a fail+=1
)
call :end_test

setlocal
set "args=/a a /b b /c c /d"
call :arg_parse arg args
endlocal

:test 4
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

setlocal
set "args=/m /s" "1 /"sw it ch" n"
call :arg_parse arg args
endlocal

:test 5
set "It=accepts spaces in the switch name"
call :start_test
if not "%arg['s 1']%"=="1" (
	set /a fail+=1
)
if not "%arg['sw it ch']%"=="1" (
	set /a fail+=1
)
call :end_test

:test 6
set "It=stores '1' in the arg[?'key'] variable"
call :start_test
if not "%arg[?'m']%"=="1" (
	set /a fail+=1
)
if not "%arg[?'s 1']%"=="1" (
	set /a fail+=1
)
if not "%arg[?'sw it ch']%"=="1" (
	set /a fail+=1
)
call :end_test
