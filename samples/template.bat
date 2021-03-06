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
		'""%windir%\System32\cscript.exe" /nologo /e:jscript "!_f0!" // !_args!"'
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

function e(e){return!(e.length<2)&&!!~c.indexOf(e.charAt(0))}Array.prototype.indexOf=function(e){for(var n=0;n<this.length;n++)if(this[n]===e)return n;return-1},RegExp.escapePattern=/[-\/\\^$*+?.()|[\]{}]/g,RegExp.escape=function(e){return e.replace(RegExp.escapePattern,"\\$&")};var n=WScript.Arguments,t=new ActiveXObject("WScript.Shell"),r=t.Environment("Process")("JABCLAP_EXPECT_VALUE_FROM"),s=parseInt(t.Environment("Process")("JABCLAP_CASE_SENSITIVE")),c=t.Environment("Process")("JABCLAP_KEY_INDICATOR")||"/",a=t.Environment("Process")("JABCLAP_PAIR_DELIMITER")||":=",p=t.Environment("Process")("JABCLAP_END_OF_OPTIONS_MARKER");/^\s+$/.test(p)&&(p=!1);var o=(s?r:r.toLowerCase()).split(" "),E=/^\s+$/.test(c),A=new RegExp("["+RegExp.escape(a)+"]"),l="",P={},f=!1,m=0,v=0,S=0,h=[],O=[];for(i=0;i<n.length;i++){var _=n.Item(i);if(h.push(_),l+="[@"+(i+1)+"]="+_+"\n",p&&_===p)E=!0;else if(!f||(f=!1,e(_)))if(!E&&e(_)){var x=_.charAt(0),g=_.slice(1),u=_.search(A),R=~u?_.slice(1,u):g,C=R.toLowerCase(),I=~u?g.slice(u):"";v++,P.hasOwnProperty(C)?P[C]++:(P[C]=1,l+="[;"+ ++S+"]="+R+"\n"),l+="[#'"+R+"']="+P[C]+"\n[?'"+R+"']=1\n[?'"+R+"'"+P[C]+"]=1\n[-'"+R+"']="+x+"\n[-'"+R+"'"+P[C]+"]="+x+"\n",s&&(l+="[`"+C+"`"+P[C]+"]="+R+"\n[`"+C+"`]="+R+"\n"),~o.indexOf(s?R:C)?I?l+="['"+R+"']="+I+"\n['"+R+"'"+P[C]+"]="+I+"\n":(~a.indexOf(" ")&&(f=!0),l+="['"+R+"']=\n"):l+="['"+g+"']=1\n['"+g+"'"+P[C]+"]=1\n"}else O.push(_),l+="["+ ++m+"]="+_+"\n";else l+="[-'"+R+"']="+x+"\n[-'"+R+"'"+P[C]+"]="+x+"\n['"+R+"']="+_+"\n['"+R+"'"+P[C]+"]="+_+"\n"}var N=new ActiveXObject("Scripting.FileSystemObject"),L=WScript.ScriptName.replace(/\?\.wsf$/i,""),d=WScript.ScriptFullName.replace(/\?\.wsf$/i,"");l+="[v]=1.1.0\n[m]=cmd\n[0]="+L+"\n[~n0]="+N.GetBaseName(L)+"\n[~x0]=."+N.GetExtensionName(L)+"\n[~nx0]="+L+"\n[~f0]="+d+"\n[~d0]="+N.GetDriveName(d)+"\n[~dp0]="+N.GetParentFolderName(d)+"\n[#a]="+i+"\n[#@]="+i+"\n[#p]="+m+"\n[#]="+m+"\n[#n]="+v+"\n[#q]="+S+"\n[#;]="+S+'\n[@]="'+h.join('" "')+'"\n[*]="'+O.join('" "')+'"\n',WScript.Echo(l);
