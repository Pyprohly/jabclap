@echo off
setlocal

set "parser=%~dp0\..\src\parser-cmd.js"

REM set "JABCLAP_EXPECT_VALUE_FROM="
REM set "JABCLAP_CASE_SENSITIVE="
REM set "JABCLAP_KEY_INDICATOR=/"
REM set "JABCLAP_PAIR_DELIMITER=:="

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
	ECHO "%_ARGS%"
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


:main
setlocal DisableDelayedExpansion
set "args=%*" || (
	>&2 echo(
	>&2 echo Malformed command line
	exit /b 1
)
call :arg_parse arg args
endlocal

set arg[
