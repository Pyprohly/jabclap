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
set "args=" a " " b c ""
call :arg_parse arg args
endlocal

:test 1
set "It=stores the correct value of positional arguments when they contain spaces"
call :start_test
if not "%arg[1]%"==" a " (
	set /a fail+=1
)
if not "%arg[2]%"==" b c " (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a g"

setlocal
set "args=" a " /a:" s s s " " b c " /g:" t " "
call :arg_parse arg args
endlocal

:test 2
set "It=stores the correct value of named arguments when they contain spaces"
call :start_test
if not "%arg['a']%"==" s s s " (
	set /a fail+=1
)
if not "%arg['g']%"==" t " (
	set /a fail+=1
)
call :end_test

set "JABCLAP_PAIR_DELIMITER=:= "

setlocal
set "args=" a " /a " s s s " " b c " /g " t " "
call :arg_parse arg args
endlocal

:test 3
set "It=stores the correct value of named arguments when they contain spaces and the key-value delimiter is a space"
call :start_test
if not "%arg['a']%"==" s s s " (
	set /a fail+=1
)
if not "%arg['g']%"==" t " (
	set /a fail+=1
)
call :end_test

setlocal
set "args="" "" """
call :arg_parse arg args
endlocal

:test 4
set "It=acknowledges empty positional arguments"
call :start_test
if not "%arg[3]%"=="" (
	set /a fail+=1
)
if %arg[#p]% neq 3 (
	set /a fail+=1
)
call :end_test

setlocal
set "args=a "b c"
call :arg_parse arg args
endlocal

:test 5
set "It=is resilient against unpaired double quotes among positional arguments"
call :start_test
if not "%arg[1]%"=="a" (
	set /a fail+=1
)
if not "%arg[2]%"=="b c" (
	set /a fail+=1
)

if %arg[#p]% neq 2 (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a"

setlocal
set "args=arg1 /a:"bc arg2"
call :arg_parse arg args
endlocal

:test 6
set "It=doesn't break when it encounters unpaired double quotes among named arguments"
call :start_test
if not "%arg[1]%"=="arg1" (
	set /a fail+=1
)
if not "%arg['a']%"=="bc arg2" (
	set /a fail+=1
)
if defined arg[2] (
	set /a fail+=1
)
call :end_test
