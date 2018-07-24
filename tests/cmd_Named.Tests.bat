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

set "JABCLAP_EXPECT_VALUE_FROM=a b"

setlocal
set "args=/a /a:b /a"
call :arg_parse arg args
endlocal

:test 1
set "It=unsets a named argument if it is missing a value"
call :start_test
if defined arg['a'] (
	set /a fail+=1
)
call :end_test

setlocal
set "args=/b:a /b /b:c"
call :arg_parse arg args
endlocal

:test 2
set "It=stores the last named argument in the main variable"
call :start_test
if not "%arg['b']%"=="c" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_KEY_INDICATOR=/-+"

setlocal
set "args=/a -b +c"
call :arg_parse arg args
endlocal

:test 3
set "It=stores the indicator"
call :start_test
if not "%arg[-'a']%"=="/" (
	set /a fail+=1
)
if not "%arg[-'b']%"=="-" (
	set /a fail+=1
)
if not "%arg[-'c']%"=="+" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=b e"

setlocal
set "args=/a /b:c -d -e=f"
call :arg_parse arg args
endlocal

:test 4
set "It=distinguishes switchs from key-value pairs when declared as such"
call :start_test
if %arg['a']% neq 1 (
	set /a fail+=1
)
if not "%arg['b']%"=="c" (
	set /a fail+=1
)
if %arg['d']% neq 1 (
	set /a fail+=1
)
if not "%arg['e']%"=="f" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a"

setlocal
set "args=/a /a:"b c" /a /a:sdf /a:c"
call :arg_parse arg args
endlocal

:test 5
set "It=stores the correct value in the positional named-argument keys"
call :start_test
if not "%arg['a'1]%"=="" (
	set /a fail+=1
)
if not "%arg['a'2]%"=="b c" (
	set /a fail+=1
)
if not "%arg['a'3]%"=="" (
	set /a fail+=1
)
if not "%arg['a'4]%"=="sdf" (
	set /a fail+=1
)
if not "%arg['a'5]%"=="c" (
	set /a fail+=1
)
if not "%arg['a'6]%"=="" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_CASE_SENSITIVE=1"

setlocal
set "args=/Key /kEy /keY /kEy /KeY"
call :arg_parse arg args
endlocal

:test 6
set "It=stores the original casing of the named arguments"
call :start_test
if not "%arg[`key`1]%"=="Key" (
	set /a fail+=1
)
if not "%arg[`key`2]%"=="kEy" (
	set /a fail+=1
)
if not "%arg[`key`3]%"=="keY" (
	set /a fail+=1
)
if not "%arg[`key`4]%"=="kEy" (
	set /a fail+=1
)
if not "%arg[`key`5]%"=="KeY" (
	set /a fail+=1
)
if not "%arg[`key`]%"=="KeY" (
	set /a fail+=1
)
call :end_test
