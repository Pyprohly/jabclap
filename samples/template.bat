0</* :

:: parser: cmd
:: hybrid: js
:: approach: safe

@echo off
setlocal

set "JABCLAP_EXPECT_VALUE_FROM="
set "JABCLAP_CASE_SENSITIVE=0"
set "JABCLAP_KEY_INDICATOR=/"
set "JABCLAP_PAIR_DELIMITER=:="
set "JABCLAP_END_OF_OPTIONS_MARKER="

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
		'cscript.exe /nologo /e:jscript "!_f0!" // !_args!'
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
	>&2 echo Malformed command line
	exit /b 2
)
call :arg_parse arg args
endlocal

set arg[

goto :eof
*/0

function e(e){return!(e.length<2)&&!!~s.indexOf(e.charAt(0))}Array.prototype.indexOf=function(e){for(var n=0;n<this.length;n++)if(this[n]===e)return n;return-1},RegExp.escapePattern=/[-\/\\^$*+?.()|[\]{}]/g,RegExp.escape=function(e){return e.replace(RegExp.escapePattern,"\\$&")};var n=WScript.Arguments,t=new ActiveXObject("WScript.Shell"),r=t.Environment("Process")("JABCLAP_EXPECT_VALUE_FROM"),c=parseInt(t.Environment("Process")("JABCLAP_CASE_SENSITIVE")),s=t.Environment("Process")("JABCLAP_KEY_INDICATOR")||"/",p=t.Environment("Process")("JABCLAP_PAIR_DELIMITER")||":=",o=t.Environment("Process")("JABCLAP_END_OF_OPTIONS_MARKER");/^\s+$/.test(o)&&(o=!1);var a=(c?r:r.toLowerCase()).split(" "),E={},S=!1,A=0,h=0,l=0,P=/^\s+$/.test(s);for(i=0;i<n.length;i++){var f=n.Item(i);if(WScript.Echo("[@"+(i+1)+"]="+f),o&&f===o)P=!0;else if(!S||(S=!1,e(f)))if(!P&&e(f)){var m=f.charAt(0),v=f.slice(1),W=f.search(new RegExp("["+RegExp.escape(p)+"]")),O=~W?f.slice(1,W):v,_=O.toLowerCase(),x=~W?v.slice(W):"";h++,E.hasOwnProperty(_)?E[_]++:(E[_]=1,WScript.Echo("[;"+ ++l+"]="+O)),WScript.Echo("[#'"+O+"']="+E[_]+"\n[?'"+O+"']=1\n[?'"+O+"'"+E[_]+"]=1\n[-'"+O+"']="+m+"\n[-'"+O+"'"+E[_]+"]="+m),c&&WScript.Echo("[`"+_+"`"+E[_]+"]="+O+"\n[`"+_+"`]="+O),~a.indexOf(c?O:_)?x?WScript.Echo("['"+O+"']="+x+"\n['"+O+"'"+E[_]+"]="+x):(~p.indexOf(" ")&&(S=!0),WScript.Echo("['"+O+"']=")):WScript.Echo("['"+v+"']=1\n['"+v+"'"+E[_]+"]=1")}else WScript.Echo("["+ ++A+"]="+f);else WScript.Echo("[-'"+O+"']="+m+"\n[-'"+O+"'"+E[O]+"]="+m+"\n['"+O+"']="+f+"\n['"+O+"'"+E[O]+"]="+f)}var g=new ActiveXObject("Scripting.FileSystemObject"),R=WScript.ScriptName.replace(/\?\.wsf$/i,""),C=WScript.ScriptFullName.replace(/\?\.wsf$/i,"");WScript.Echo("[v]=1.0\n[m]=cmd\n[0]="+R+"\n[~n0]="+g.GetBaseName(R)+"\n[~x0]=."+g.GetExtensionName(R)+"\n[~nx0]="+R+"\n[~f0]="+C+"\n[~d0]="+g.GetDriveName(C)+"\n[~dp0]="+g.GetParentFolderName(C)+"\n[#a]="+i+"\n[#@]="+i+"\n[#p]="+A+"\n[#]="+A+"\n[#n]="+h+"\n[#q]="+l+"\n[#;]="+l);
