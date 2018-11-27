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

set "JABCLAP_EXPECT_VALUE_FROM=key"

setlocal
set "args=-key=value"
call :arg_parse arg args
endlocal

:test 1
set "It=stores the correct value for a key"
call :start_test
if not "%arg['key']%"=="value" (
	set /a fail+=1
)
call :end_test

:test 2
set "It=stores the correct value in the positional named argument key"
call :start_test
if not "%arg['key'1]%"=="value" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a"

setlocal
set "args=m -a=b n"
call :arg_parse arg args
endlocal

:test 3
set "It=correctly stores the value of an option with a equals symbol as a delimiter"
call :start_test
if not "%arg['a']%"=="b" (
	set /a fail+=1
)
if not "%arg['a'1]%"=="b" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_PAIR_DELIMITER== "

setlocal
set "args=m -a b n"
call :arg_parse arg args
endlocal

:test 4
set "It=correctly stores the value of an option with a space as a delimiter"
call :start_test
if not "%arg['a']%"=="b" (
	set /a fail+=1
)
if not "%arg['a'1]%"=="b" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=m -ab n"
call :arg_parse arg args
endlocal

:test 5
set "It=correctly stores the value of an option with no delimiter"
call :start_test
if not "%arg['a']%"=="b" (
	set /a fail+=1
)
if not "%arg['a'1]%"=="b" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=c"

setlocal
set "args=-abcde"
call :arg_parse arg args
endlocal

:test 6
set "It=correctly stores the value of an option in a flag bundle"
call :start_test
if not "%arg['a']%"=="1" (
	set /a fail+=1
)
if not "%arg['b']%"=="1" (
	set /a fail+=1
)
if not "%arg['c']%"=="de" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a"

setlocal
set "args=m -a="b "c n"
call :arg_parse arg args
endlocal

:test 7
set "It=stores the correct value for a given key when the value contains spaces"
call :start_test
if not "%arg['a']%"=="b c" (
	set /a fail+=1
)
if not "%arg['a'1]%"=="b c" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a e i"

setlocal
set "args=-a="b "c -d -e"=f g" -h "-i=j k""
call :arg_parse arg args
endlocal

:test 8
set "It=stores the correct values when multiple named arguments are used"
call :start_test
if not "%arg['a']%"=="b c" (
	set /a fail+=1
)
if not "%arg['a'1]%"=="b c" (
	set /a fail+=1
)
if not "%arg['e']%"=="f g" (
	set /a fail+=1
)
if not "%arg['e'1]%"=="f g" (
	set /a fail+=1
)
if not "%arg['i']%"=="j k" (
	set /a fail+=1
)
if not "%arg['i'1]%"=="j k" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a -a=x -a=y -a=z"
call :arg_parse arg args
endlocal

:test 9
set "It=stores the last duplicate key's value in the main variable"
call :start_test
if not "%arg['a']%"=="z" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a -a=x -a=y -a"
call :arg_parse arg args
endlocal

:test 10
set "It=unsets the key if the last duplicate key is a switch"
call :start_test
if defined arg['a'] (
	set /a fail+=1
)
call :end_test

setlocal
set "args=-a="b "c -a -a"=f g" "-a=j k""
call :arg_parse arg args
endlocal

:test 11
set "It=correctly stores the values of duplicate named arguments"
call :start_test
if not "%arg['a'1]%"=="b c" (
	set /a fail+=1
)
if defined arg['a'2] (
	set /a fail+=1
)
if not "%arg['a'3]%"=="f g" (
	set /a fail+=1
)
if not "%arg['a'4]%"=="j k" (
	set /a fail+=1
)
if not "%arg['a']%"=="j k" (
	set /a fail+=1
)
call :end_test

:test 12
set "It=stores '1' in the arg[?'key'] variable"
call :start_test
if not "%arg[?'a'1]%"=="1" (
	set /a fail+=1
)
if not "%arg[?'a'2]%"=="1" (
	set /a fail+=1
)
if not "%arg[?'a'3]%"=="1" (
	set /a fail+=1
)
if not "%arg[?'a'4]%"=="1" (
	set /a fail+=1
)
if not "%arg[?'a']%"=="1" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a b c d"
set "JABCLAP_KEY_INDICATOR=/-"
set "JABCLAP_PAIR_DELIMITER=:= "

setlocal
set "args=/a:a:b:c: /b=a=b=c= -c:::a:: -d=:=:=:="
call :arg_parse arg args
endlocal

:test 13
set "It=stores the correct value when key-value separators are used in the value"
call :start_test
if not "%arg['a']%"=="a:b:c:" (
	set /a fail+=1
)
if not "%arg['b']%"=="a=b=c=" (
	set /a fail+=1
)
if not "%arg['c']%"=="::a::" (
	set /a fail+=1
)
if not "%arg['d']%"==":=:=:=" (
	set /a fail+=1
)
call :end_test

setlocal
set "args=/a=b=c,d(e)f g"
call :arg_parse arg args
endlocal

:test 14
set "It=correctly stores values when they contain some delimiter characters"
call :start_test
if not "%arg['a']%"=="b=c,d(e)f" (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=a b"
set "JABCLAP_KEY_INDICATOR=-"
set "JABCLAP_PAIR_DELIMITER== "

setlocal
set "args=-a -b"
call :arg_parse arg args
endlocal

:test 15
set "It=doesn't consume the next argument if it is a named argument (short option)"
call :start_test
if defined arg['a'] (
	set /a fail+=1
)
call :end_test

set "JABCLAP_EXPECT_VALUE_FROM=-opt1 -opt2"
set "JABCLAP_KEY_INDICATOR=-"
set "JABCLAP_PAIR_DELIMITER== "

setlocal
set "args=--opt1 --opt2"
call :arg_parse arg args
endlocal

:test 16
set "It=doesn't consume the next argument if it is a named argument (long option)"
call :start_test
if defined arg['-opt1'] (
	set /a fail+=1
)
call :end_test
