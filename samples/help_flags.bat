0</* :

:: parser: unix
:: hybrid: js
:: approach: safe

:::!{prog}! [options]
:::
:::[1mDESCRIPTION[m
:::    A command that does nothing but show this usage text when either
:::    any of the help flags are used or the command is invoked with no
:::    arguments. Otherwise "Hello World^!" is echoed.
:::
:::[1mOPTIONS[m
:::    -h, -?, --help
:::        Output usage information.
:::
:::    -hh, -??, --help-paged
:::        Output paged usage information.
:::

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
		'""%windir%\System32\cscript.exe" /nologo /e:jscript "!_f0!" // !_args!"'
	) do (
		endlocal & endlocal
		set "%~1%%I"
		setlocal & setlocal
	)
	endlocal
)

:validate_arguments
setlocal EnableDelayedExpansion
	if defined arg['?'] (
		call :usage
		goto 2>nul & exit /b 0
	)
	if defined arg['-help'] (
		call :usage
		goto 2>nul & exit /b 0
	)
	if "%arg[#'h']%" equ "1" (
		call :usage
		goto 2>nul & exit /b 0
	)
	if "%arg[#'h']%" geq "2" (
		call :usage paged
		goto 2>nul & exit /b 0
	)
	if defined arg['??'] (
		call :usage paged
		goto 2>nul & exit /b 0
	)
	if defined arg['-help-paged'] (
		call :usage paged
		goto 2>nul & exit /b 0
	)
	if %arg[#a]% equ 0 (
		call :usage >&2
		goto 2>nul & exit /b 1
	)

	set "expected_keys=? ?? -help h -help-paged"
	for /l %%I in (1 1 %arg[#;]%) do (
		echo !arg[;%%I]!| findstr -bei "!expected_keys!" >nul || (
			echo %arg[~nx0]%: invalid option -- !arg[;%%I]!
			exit /b 1
		)
	)
endlocal
exit /b 0

:usage [Section]
setlocal EnableDelayedExpansion
	set "{prog}=%~nx0"

	if "%~1"=="" (
		for /f "tokens=1,* delims=:" %%A in (' findstr -bn ":::[^:] :::$" "%~f0" ') do echo(%%B
	) else if "%~1"=="paged" (
		set "temp_file=%temp%\%~n0-usage.txt"
		>"!temp_file!" (
			for /f "tokens=1,* delims=:" %%A in (' findstr -bn ":::[^:] :::$" "%~f0" ') do echo(%%B
		)
		more /e "!temp_file!"
		if exist "!temp_file!" del "!temp_file!"
	)
endlocal
goto :eof


:main
setlocal DisableDelayedExpansion
set "args=%*" || (
	>&2 echo Malformed command line
	exit /b 2
)
call :arg_parse arg args
endlocal

call :validate_arguments >&2 || exit /b 2

echo Hello World!

goto :eof
*/0

function e(e){return!(e.length<2)&&!!~o.indexOf(e.charAt(0))}function n(){f++,h.hasOwnProperty(L)?h[L]++:(h[L]=1,WScript.Echo("[;"+ ++l+"]="+g)),WScript.Echo("[#'"+g+"']="+h[L]+"\n[?'"+g+"']=1\n[?'"+g+"'"+h[L]+"]=1\n[-'"+g+"']="+P+"\n[-'"+g+"'"+h[L]+"]="+P),s&&WScript.Echo("[`"+L+"`"+h[L]+"]="+g+"\n[`"+L+"`]="+g)}Array.prototype.indexOf=function(e){for(var n=0;n<this.length;n++)if(this[n]===e)return n;return-1},RegExp.escapePattern=/[-\/\\^$*+?.()|[\]{}]/g,RegExp.escape=function(e){return e.replace(RegExp.escapePattern,"\\$&")};var t=WScript.Arguments,r=new ActiveXObject("WScript.Shell"),c=r.Environment("Process")("JABCLAP_EXPECT_VALUE_FROM"),s=parseInt(r.Environment("Process")("JABCLAP_CASE_SENSITIVE"));isNaN(s)&&(s=!0);var a=parseInt(r.Environment("Process")("JABCLAP_FLAG_BUNDLING"));isNaN(a)&&(a=!0);var o=r.Environment("Process")("JABCLAP_KEY_INDICATOR")||"-",p=r.Environment("Process")("JABCLAP_PAIR_DELIMITER")||"= ",E=(s?c:c.toLowerCase()).split(" "),h={},S=!1,A=0,f=0,l=0,v=/^\s+$/.test(o);for(i=0;i<t.length;i++){var W=t.Item(i);if(WScript.Echo("[@"+(i+1)+"]="+W),"--"!==W)if(!S||(S=!1,e(W)))if(!v&&e(W)){var P=W.charAt(0),m=W.slice(1),x=W.search(new RegExp("["+RegExp.escape(p)+"]")),N=W.charAt(x),g=~x?W.slice(1,x):m,L=g.toLowerCase(),O=~x?m.slice(x):"";if(~E.indexOf(s?g:L))n(),O?WScript.Echo("['"+g+"']="+O+"\n['"+g+"'"+h[L]+"]="+O):(WScript.Echo("['"+g+"']="),~p.indexOf(" ")&&(S=!0));else if(a&&/[a-z0-9]/i.test(W.charAt(1)))for(var u=0;u<m.length&&(g=m.charAt(u),L=g.toLowerCase(),!/[^a-z0-9]/i.test(g));u++){if(n(),~E.indexOf(g)){(O=m.slice(u+1))?WScript.Echo("['"+g+"']="+O+"\n['"+g+"'"+h[L]+"]="+O):(~p.indexOf(" ")&&(S=!0),WScript.Echo("['"+g+"']="));break}WScript.Echo("['"+g+"']=1\n['"+g+"'"+h[L]+"]=1")}else n(),WScript.Echo("['"+m+"']=1\n['"+m+"'"+h[L]+"]=1")}else WScript.Echo("["+ ++A+"]="+W);else WScript.Echo("[-'"+g+"']="+P+"\n[-'"+g+"'"+h[g]+"]="+P+"\n['"+g+"']="+W+"\n['"+g+"'"+h[g]+"]="+W);else v=!0}var C=new ActiveXObject("Scripting.FileSystemObject"),I=WScript.ScriptName.replace(/\?\.wsf$/i,""),_=WScript.ScriptFullName.replace(/\?\.wsf$/i,"");WScript.Echo("[v]=1.0\n[m]=unix\n[0]="+I+"\n[~n0]="+C.GetBaseName(I)+"\n[~x0]=."+C.GetExtensionName(I)+"\n[~nx0]="+I+"\n[~f0]="+_+"\n[~d0]="+C.GetDriveName(_)+"\n[~dp0]="+C.GetParentFolderName(_)+"\n[#a]="+i+"\n[#@]="+i+"\n[#p]="+A+"\n[#]="+A+"\n[#n]="+f+"\n[#q]="+l+"\n[#;]="+l);
