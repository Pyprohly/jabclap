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

set "JABCLAP_EXPECT_VALUE_FROM=d"

setlocal
set "args=-aba -cdef foo --opt bar -- --opt --opt2 baz"
call :arg_parse arg args
endlocal

:test 4
set "It=correctly stores a space separated list of arguments"
setlocal EnableDelayedExpansion
call :start_test
set "value="-aba" "-cdef" "foo" "--opt" "bar" "--" "--opt" "--opt2" "baz""
if not "!arg[@]!"=="!value!" (
	set /a fail+=1
)
set "value="foo" "bar" "--opt" "--opt2" "baz""
if not "!arg[*]!"=="!value!" (
	set /a fail+=1
)
endlocal & set /a "fail=%fail%"
call :end_test

:test 1
set "It=correctly counts the total number of arguments"
call :start_test
if %arg[#a]% neq 9 (
	set /a fail+=1
)
if %arg[#@]% neq 9 (
	set /a fail+=1
)
call :end_test

:test 2
set "It=correctly counts the positional arguments"
call :start_test
if %arg[#p]% neq 5 (
	set /a fail+=1
)
if %arg[#]% neq 5 (
	set /a fail+=1
)
call :end_test

:test 3
set "It=correctly counts the named arguments"
call :start_test
if %arg[#n]% neq 6 (
	set /a fail+=1
)
call :end_test

:test 4
set "It=correctly counts unique named arguments"
call :start_test
if %arg[#q]% neq 5 (
	set /a fail+=1
)
if %arg[#;]% neq 5 (
	set /a fail+=1
)
call :end_test

setlocal
set "args=- -"
call :arg_parse arg args
endlocal

:test 5
set "It=treats option indicator characters on their own as a positional"
call :start_test
if not "%arg[1]%"=="-" (
	set /a fail+=1
)

if not "%arg[2]%"=="-" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=aBc AbC"
call :arg_parse arg args
endlocal

:test 6
set "It=preserves casing among positional parameters"
call :start_test
if not "%arg[1]%"=="aBc" (
	set /a fail+=1
)
if not "%arg[2]%"=="AbC" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=KEY"
set "JABCLAP_CASE_SENSITIVE="

setlocal
set "args=/key:asdf"
call :arg_parse arg args
endlocal

:test 7
set "It=is case sensitive by default"
call :start_test
if not "%arg['key'1]%"=="" (
	set /a fail+=1
)
if not "%arg['key']%"=="" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=KEY"
set "JABCLAP_CASE_SENSITIVE=0"

setlocal
set "args=-key=asdf"
call :arg_parse arg args
endlocal

:test 8
set "It=respects the case sensitivity setting"
call :start_test
if not "%arg['key'1]%"=="asdf" (
	set /a fail+=1
)
if not "%arg['key']%"=="asdf" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_CASE_SENSITIVE=1"
set "JABCLAP_FLAG_BUNDLING=0"

setlocal
set "args=-Abc -aBc -abC"
call :arg_parse arg args
endlocal

:test 9
set "It=stores the correct capitalisation of keys"
call :start_test
if not "%arg[`abc`1]%"=="Abc" (
	set /a fail+=1
)
if not "%arg[`abc`2]%"=="aBc" (
	set /a fail+=1
)
if not "%arg[`abc`3]%"=="abC" (
	set /a fail+=1
)
if not "%arg[`abc`]%"=="abC" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_CASE_SENSITIVE=0"
set "JABCLAP_FLAG_BUNDLING=0"

setlocal
set "args=-Abc -aBc -abC -e -E -P -p"
call :arg_parse arg args
endlocal

:test 10
set "It=stores the capitalisation of the first instance in the arg[;key] variable"
call :start_test
if not "%arg[;1]%"=="Abc" (
	set /a fail+=1
)
if not "%arg[;2]%"=="e" (
	set /a fail+=1
)
if not "%arg[;3]%"=="P" (
	set /a fail+=1
)
call :end_test
