0</* :

:: parser: cmd
:: hybrid: js
:: approach: safe

:: v1.0.2
:::!{prog}! [/n] [/fg [4mcolor[m] [/bg [4mcolor[m] [[4mstring[m...]
:::
:::[1mSYNOPSIS[m
:::    Displays a custom message to the console.
:::
:::[1mDESCRIPTION[m
:::    This command prints its arguments to the standard output. The colour
:::    of the message can be specified using /fg and /bg for the foreground
:::    and background respectively. If no string is specified then input is
:::    read from the standard input stream. Enter ^Z on a new line to stop
:::    reading.
:::
:::    The [4mcolor[m parameter is a single hexadecimal digit (from 0 to F). The
:::    corresponding colours are the same as in the `color` command. See
:::    `color /?`.
:::
:::[1mOPTIONS[m
:::    /?         Print usage summary and exit.
:::    /n         Do not end the message with a newline character.
:::    /fg [4mcolor[m  Specify the foreground color for the message.
:::    /bg [4mcolor[m  Specify the background color for the message.
:::


@echo off
setlocal

set "JABCLAP_EXPECT_VALUE_FROM=fg bg"
set "JABCLAP_PAIR_DELIMITER=:= "
set "JABCLAP_END_OF_OPTIONS_MARKER=//"

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

	set "expected_keys=? n fg bg"
	for /l %%I in (1 1 %arg[#;]%) do (
		echo !arg[;%%I]!| findstr -bei "!expected_keys!" >nul || (
			echo Unexpected named argument '!arg[;%%I]!'
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
		>nul copy nul "!temp_file!"
		for /f "tokens=1,* delims=:" %%A in (' findstr -bn ":::[^:] :::$" "%~f0" ') do >>"!temp_file!" echo(%%B
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

setlocal EnableDelayedExpansion

set "input=from_args"
if %arg[#p]% equ 0 (
	set "input=from_stdin"
)

if defined arg['fg'] (
	echo(%arg['fg']%| findstr -bei "[0-9a-f]" >nul || (
		>&2 echo Invalid colour specification
		exit /b 1
	)
)

if defined arg['bg'] (
	echo(%arg['bg']%| findstr -bei "[0-9a-f]" >nul || (
		>&2 echo Invalid colour specification
		exit /b 1
	)
)

:: Foreground
set "fg_color_ctrl['0']=30"
set "fg_color_ctrl['1']=34"
set "fg_color_ctrl['2']=32"
set "fg_color_ctrl['3']=36"
set "fg_color_ctrl['4']=31"
set "fg_color_ctrl['5']=35"
set "fg_color_ctrl['6']=33"
set "fg_color_ctrl['7']=37"
set "fg_color_ctrl['8']=90"
set "fg_color_ctrl['9']=94"
set "fg_color_ctrl['a']=92"
set "fg_color_ctrl['b']=96"
set "fg_color_ctrl['c']=91"
set "fg_color_ctrl['d']=95"
set "fg_color_ctrl['e']=93"
set "fg_color_ctrl['f']=97"

:: Background
set "bg_color_ctrl['0']=40"
set "bg_color_ctrl['1']=44"
set "bg_color_ctrl['2']=42"
set "bg_color_ctrl['3']=46"
set "bg_color_ctrl['4']=41"
set "bg_color_ctrl['5']=45"
set "bg_color_ctrl['6']=43"
set "bg_color_ctrl['7']=47"
set "bg_color_ctrl['8']=100"
set "bg_color_ctrl['9']=104"
set "bg_color_ctrl['a']=102"
set "bg_color_ctrl['b']=106"
set "bg_color_ctrl['c']=101"
set "bg_color_ctrl['d']=105"
set "bg_color_ctrl['e']=103"
set "bg_color_ctrl['f']=107"

set "csi="
if defined arg['fg'] (
	set "csi=!fg_color_ctrl['%arg['fg']%']!"
)
if defined arg['bg'] (
	if defined csi (
		set "csi=%csi%;"
	)
	set "csi=!csi!!bg_color_ctrl['%arg['bg']%']!"
)

set "ctl_seq_start="
set "ctl_seq_end="
if defined csi (
	set "ctl_seq_start=[%csi%m"
)
if defined ctl_seq_start (
	set "ctl_seq_end=[m"
)

set/p=%ctl_seq_start%<nul
if "%input%"=="from_args" (
	for /f %%G in (' "prompt $H & for %%_ in (1) do rem" ') do set "BS=%%G"
	for /l %%I in (1 1 %arg[#]%) do (
		if %%I equ 1 (
			set/p"=!arg[%%I]!"<nul
		) else (
			set/p"=.!BS! !arg[%%I]!"<nul
		)
	)
	if not defined arg['n'] (
		echo(
	)
) else (
	setlocal DisableDelayedExpansion
	for /f "delims=" %%L in ('more') do (
		echo(%%L
	)
	endlocal
)
set/p=%ctl_seq_end%<nul

exit /b 0
*/0

function e(e){return!(e.length<2)&&!!~s.indexOf(e.charAt(0))}Array.prototype.indexOf=function(e){for(var n=0;n<this.length;n++)if(this[n]===e)return n;return-1},RegExp.escapePattern=/[-\/\\^$*+?.()|[\]{}]/g,RegExp.escape=function(e){return e.replace(RegExp.escapePattern,"\\$&")};var n=WScript.Arguments,t=new ActiveXObject("WScript.Shell"),r=t.Environment("Process")("JABCLAP_EXPECT_VALUE_FROM"),c=parseInt(t.Environment("Process")("JABCLAP_CASE_SENSITIVE")),s=t.Environment("Process")("JABCLAP_KEY_INDICATOR")||"/",p=t.Environment("Process")("JABCLAP_PAIR_DELIMITER")||":=",o=t.Environment("Process")("JABCLAP_END_OF_OPTIONS_MARKER");/^\s+$/.test(o)&&(o=!1);var a=(c?r:r.toLowerCase()).split(" "),E={},S=!1,A=0,h=0,l=0,P=/^\s+$/.test(s);for(i=0;i<n.length;i++){var f=n.Item(i);if(WScript.Echo("[@"+(i+1)+"]="+f),o&&f===o)P=!0;else if(!S||(S=!1,e(f)))if(!P&&e(f)){var m=f.charAt(0),v=f.slice(1),W=f.search(new RegExp("["+RegExp.escape(p)+"]")),O=~W?f.slice(1,W):v,_=O.toLowerCase(),x=~W?v.slice(W):"";h++,E.hasOwnProperty(_)?E[_]++:(E[_]=1,WScript.Echo("[;"+ ++l+"]="+O)),WScript.Echo("[#'"+O+"']="+E[_]+"\n[?'"+O+"']=1\n[?'"+O+"'"+E[_]+"]=1\n[-'"+O+"']="+m+"\n[-'"+O+"'"+E[_]+"]="+m),c&&WScript.Echo("[`"+_+"`"+E[_]+"]="+O+"\n[`"+_+"`]="+O),~a.indexOf(c?O:_)?x?WScript.Echo("['"+O+"']="+x+"\n['"+O+"'"+E[_]+"]="+x):(~p.indexOf(" ")&&(S=!0),WScript.Echo("['"+O+"']=")):WScript.Echo("['"+v+"']=1\n['"+v+"'"+E[_]+"]=1")}else WScript.Echo("["+ ++A+"]="+f);else WScript.Echo("[-'"+O+"']="+m+"\n[-'"+O+"'"+E[O]+"]="+m+"\n['"+O+"']="+f+"\n['"+O+"'"+E[O]+"]="+f)}var g=new ActiveXObject("Scripting.FileSystemObject"),R=WScript.ScriptName.replace(/\?\.wsf$/i,""),C=WScript.ScriptFullName.replace(/\?\.wsf$/i,"");WScript.Echo("[v]=1.0\n[m]=cmd\n[0]="+R+"\n[~n0]="+g.GetBaseName(R)+"\n[~x0]=."+g.GetExtensionName(R)+"\n[~nx0]="+R+"\n[~f0]="+C+"\n[~d0]="+g.GetDriveName(C)+"\n[~dp0]="+g.GetParentFolderName(C)+"\n[#a]="+i+"\n[#@]="+i+"\n[#p]="+A+"\n[#]="+A+"\n[#n]="+h+"\n[#q]="+l+"\n[#;]="+l);
