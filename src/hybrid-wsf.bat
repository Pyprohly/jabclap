exit
<?xml :
: version="1.0" encoding="UTF-8" ?><!--

::DOC::

@echo off
setlocal

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
		'""%windir%\System32\cscript.exe" /nologo /job:cli-parser "!_f0!?.wsf" // !_args!"'
	) do (
		endlocal & endlocal
		set "%~1%%I"
		setlocal & setlocal
	)
	endlocal
)


:main

REM # __ METHOD 1 __
setlocal DisableDelayedExpansion
set "args=%*" || (
	>&2 echo Malformed command line
	exit /b 2
)
call :arg_parse arg args
endlocal


REM # __ METHOD 2 __
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
	'"%windir%\System32\cscript.exe" /nologo /job:cli-parser "%~f0?.wsf" // !args!'
) do (
	set "arg%%I"
)


::BODY::

exit /b
: -->

<package>
	<job id="cli-parser">
		<script language="JScript">
			<![CDATA[
				::PARSER::
			]]>
		</script>
	</job>
</package>
