exit
0</* :

::DOC::

@echo off
setlocal

goto :main

:arg_parse OutVar ArgsVar
setlocal DisableDelayedExpansion
	REM Store as local variables to take advantage of early
	REM expansion in the erroneous `goto`.
	set "_f0=%~f0"
	setlocal EnableDelayedExpansion
	set "_args=!%~2!"
goto 2>nul & ( %= REM 2 implicit `endlocal`s =%
	REM This `endlocal` removes the `args` (%~2) variable, hence
	REM the need for having it evaluated in the above line.
	endlocal
	REM This `endlocal` removes the variables in the calling line’s
	REM scope as well as the variables defined at the start of this
	REM function. This means `%args%` (%~2) is removed, hence the
	REM need for having it evaluated in the line above.
	for /f "tokens=1 delims==" %%I in (' 2^>nul set "%~1[" ') do set "%%I="
	setlocal DisableDelayedExpansion
	set "_f0=%_f0%"
	set "_args=%_args%"
	setlocal EnableDelayedExpansion
	for /f "delims=" %%I in (
		'cscript.exe /nologo /e:jscript "!_f0!" // !_args!'
	) do (
		endlocal & endlocal
		set "%~1%%I"
		setlocal & setlocal
	)
	endlocal
)


:main

REM # __ METHOD 1 __
REM Deliberately manage scoping. This way the batch coder
REM is free to add `setlocal EnableDelayedExpansion` to the top
REM of the script without disturbing the system...
setlocal DisableDelayedExpansion
set "args=%*" || (
	>&2 echo Malformed command line
	exit /b 2
)
REM ... A side effect of this is that the call to the parser must
REM be done in this same sub-scope if `%args%` is to be accessed.
call :arg_parse arg args
endlocal
REM ^^ METHOD 1 ^^


REM # __ METHOD 2 __
REM A faster but less safe alternative.
REM Does not support exclamation mark characters.
REM Method 1 becomes increasingly slow as the file size increases.
set "args=%*" || (
	>&2 echo Malformed command line
	exit /b 2
)
REM ASSERTION
if not "^!"=="^!^" (
	>&2 echo ASSERT: requires delayed expansion
	exit /b 6
)
for /f "delims=" %%I in (
	'cscript.exe /nologo /e:jscript "%~f0" // !args!'
) do (
	set "arg%%I"
)
REM ^^ METHOD 2 ^^


::BODY::

exit /b
*/0

::PARSER::