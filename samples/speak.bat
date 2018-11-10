<?xml :
: version="1.0" encoding="UTF-8" ?><!--

:: parser: unix
:: hybrid: wsf
:: approach: safe

:: v1.0.1
:::Convert text to audible speech
:::
:::!{prog}! [-a] [-v !ESC![4mvoice!ESC![m] [-r !ESC![4mrate!ESC![m] [-o !ESC![4moutfile!ESC![m] [-f !ESC![4mfile!ESC![m | !ESC![4mtext!ESC![m...]
:::
:::    This command uses the SAPI.SpVoice COM object to bring text-to-speech
:::    capabilities to the command line. The output audio can optionally be
:::    saved to a WAV file.
:::
:::    If neither text nor -f is specified, input is read from the standard
:::    input stream.
:::
:::!ESC![1mOPTIONS!ESC![m
:::    !ESC![4mtext!ESC![m
:::        Specify the text to be converted to audio. Multiple arguments will
:::        be collected into a space separated string.
:::
:::    -f !ESC![4mfile!ESC![m, --input-file=!ESC![4mfile!ESC![m
:::        Specify the file to be spoken. The file may contain SAPI XML TTS
:::        markup. See the link below. -f is ignored if both text and -f are
:::        specified.
:::
:::        https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ms717077(v=vs.85)
:::
:::    -v !ESC![4mvoice!ESC![m, --voice=!ESC![4mvoice!ESC![m
:::        Specify the voice to be used. A list of voices can be obtained
:::        by specifying '?' as the voice. If the voice cannot be found the
:::        default voice is used.
:::
:::    -r !ESC![4mrate!ESC![m, --rate=!ESC![4mrate!ESC![m
:::        The speech rate to use. Specify a number from -10 to 10 inclusive.
:::        The default rate is 0.
:::
:::    -o !ESC![4mfile!ESC![m, --output-file=!ESC![4mfile!ESC![m
:::        Specify the path for a WAV audio file to be written.
:::
:::    -h, -?, --help
:::        Output usage information.
:::
:::    -hh, --help-paged
:::        Output paged usage information.


@echo off
setlocal

set "JABCLAP_EXPECT_VALUE_FROM=f -input-file v -voice r -rate o -output-file"

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
		'cscript.exe /nologo /job:cli-parser "!_f0!?.wsf" // !_args!'
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

	set "expected_keys=? ?? -help h -help-paged %JABCLAP_EXPECT_VALUE_FROM%"
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
	for /f %%C in ('echo prompt $E^| cmd') do set "ESC=%%C"

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

set "voice=%arg['-voice']%"
if not defined voice (
	set "voice=%arg['v']%"
)

if "%voice%"=="?" (
	cscript.exe /nologo /job:list-voices "%arg[~f0]%?.wsf"
	exit /b 0
)

set /a rate=0
if defined arg['-rate'] (
	set /a "rate=%arg['-rate']%"
) else if defined arg['r'] (
	set /a "rate=%arg['r']%"
)

if %rate% gtr 10 (
	>&2 echo %arg[~nx0]%: rate must be a value between -10 to 10
	exit /b 1
)
if %rate% lss -10 (
	>&2 echo %arg[~nx0]%: rate must be a value between -10 to 10
	exit /b 1
)

set "in_file=%arg['-input-file']%"
if not defined in_file (
	set "in_file=%arg['f']%"
)

set "out_file=%arg['-output-file']%"
if not defined out_file (
	set "out_file=%arg['o']%"
)

setlocal EnableDelayedExpansion
set "positionals="
if %arg[#]% gtr 0 (
	for /l %%I in (1 1 %arg[#]%) do (
		set "positionals=!positionals! !arg[%%I]!"
	)
) else if not defined in_file (
	for /f "delims=" %%L in ('more') do (
		set "positionals=!positionals! %%L"
	)
)

set "arg_in_file="
if defined in_file (
	set "arg_in_file=/f:"%in_file%""
)

set "arg_out_file="
if defined out_file (
	set "arg_out_file=/o:"%out_file%""
)

set "arg_voice="
if defined voice (
	set "arg_voice=/v:"%voice%""
)

set "err="
for /f "delims=" %%I in ('
	2^>^&1 cscript.exe /nologo /job:tts "%arg[~f0]%?.wsf" %arg_in_file% %arg_out_file% %arg_voice% /r:"%rate%" // !positionals!
') do (
	set "err=%%I"
)

if defined err (
	echo !err!| findstr "File not found$" >nul && (
		>&2 echo %arg[~nx0]%: the input file could not be found
		exit /b 1
	)
	echo !err!| findstr "Invalid procedure call or argument$" >nul && (
		>&2 echo %arg[~nx0]%: the output destination could not be accessed
		exit /b 1
	)
)

goto :eof
: -->

<package>
	<job id="cli-parser">
		<script language="JScript">
			<![CDATA[
				function e(e){return!(e.length<2)&&!!~o.indexOf(e.charAt(0))}function n(){f++,h.hasOwnProperty(L)?h[L]++:(h[L]=1,WScript.Echo("[;"+ ++l+"]="+g)),WScript.Echo("[#'"+g+"']="+h[L]+"\n[?'"+g+"']=1\n[?'"+g+"'"+h[L]+"]=1\n[-'"+g+"']="+P+"\n[-'"+g+"'"+h[L]+"]="+P),s&&WScript.Echo("[`"+L+"`"+h[L]+"]="+g+"\n[`"+L+"`]="+g)}Array.prototype.indexOf=function(e){for(var n=0;n<this.length;n++)if(this[n]===e)return n;return-1},RegExp.escapePattern=/[-\/\\^$*+?.()|[\]{}]/g,RegExp.escape=function(e){return e.replace(RegExp.escapePattern,"\\$&")};var t=WScript.Arguments,r=new ActiveXObject("WScript.Shell"),c=r.Environment("Process")("JABCLAP_EXPECT_VALUE_FROM"),s=parseInt(r.Environment("Process")("JABCLAP_CASE_SENSITIVE"));isNaN(s)&&(s=!0);var a=parseInt(r.Environment("Process")("JABCLAP_FLAG_BUNDLING"));isNaN(a)&&(a=!0);var o=r.Environment("Process")("JABCLAP_KEY_INDICATOR")||"-",p=r.Environment("Process")("JABCLAP_PAIR_DELIMITER")||"= ",E=(s?c:c.toLowerCase()).split(" "),h={},S=!1,A=0,f=0,l=0,v=/^\s+$/.test(o);for(i=0;i<t.length;i++){var W=t.Item(i);if(WScript.Echo("[@"+(i+1)+"]="+W),"--"!==W)if(!S||(S=!1,e(W)))if(!v&&e(W)){var P=W.charAt(0),m=W.slice(1),x=W.search(new RegExp("["+RegExp.escape(p)+"]")),N=W.charAt(x),g=~x?W.slice(1,x):m,L=g.toLowerCase(),O=~x?m.slice(x):"";if(~E.indexOf(s?g:L))n(),O?WScript.Echo("['"+g+"']="+O+"\n['"+g+"'"+h[L]+"]="+O):(WScript.Echo("['"+g+"']="),~p.indexOf(" ")&&(S=!0));else if(a&&/[a-z0-9]/i.test(W.charAt(1)))for(var u=0;u<m.length&&(g=m.charAt(u),L=g.toLowerCase(),!/[^a-z0-9]/i.test(g));u++){if(n(),~E.indexOf(g)){(O=m.slice(u+1))?WScript.Echo("['"+g+"']="+O+"\n['"+g+"'"+h[L]+"]="+O):(~p.indexOf(" ")&&(S=!0),WScript.Echo("['"+g+"']="));break}WScript.Echo("['"+g+"']=1\n['"+g+"'"+h[L]+"]=1")}else n(),WScript.Echo("['"+m+"']=1\n['"+m+"'"+h[L]+"]=1")}else WScript.Echo("["+ ++A+"]="+W);else WScript.Echo("[-'"+g+"']="+P+"\n[-'"+g+"'"+h[g]+"]="+P+"\n['"+g+"']="+W+"\n['"+g+"'"+h[g]+"]="+W);else v=!0}var C=new ActiveXObject("Scripting.FileSystemObject"),I=WScript.ScriptName.replace(/\?\.wsf$/i,""),_=WScript.ScriptFullName.replace(/\?\.wsf$/i,"");WScript.Echo("[v]=1.0\n[m]=unix\n[0]="+I+"\n[~n0]="+C.GetBaseName(I)+"\n[~x0]=."+C.GetExtensionName(I)+"\n[~nx0]="+I+"\n[~f0]="+_+"\n[~d0]="+C.GetDriveName(_)+"\n[~dp0]="+C.GetParentFolderName(_)+"\n[#a]="+i+"\n[#@]="+i+"\n[#p]="+A+"\n[#]="+A+"\n[#n]="+f+"\n[#q]="+l+"\n[#;]="+l);
			]]>
		</script>
	</job>
	<job id="list-voices">
		<script language="JScript">
			<![CDATA[
				var sapi = new ActiveXObject('SAPI.SpVoice')
				voices = new Enumerator(sapi.GetVoices())
				while (!voices.atEnd()) {
					WScript.Echo(voices.item().GetDescription())
					voices.moveNext()
				}
			]]>
		</script>
	</job>
	<job id="tts">
		<script language="JScript">
			<![CDATA[
				var args = WScript.Arguments
				var namedArgs = WScript.Arguments.Named
				var positionalArgs = WScript.Arguments.Unnamed

				var fso = new ActiveXObject('Scripting.FileSystemObject')
				var stderr = fso.GetStandardStream(2)
				var sapi = new ActiveXObject('SAPI.SpVoice')

				var parameterSet = 'from_args'

				if (namedArgs.Exists('f')) {
					parameterSet = 'from_file'
					var inFile = namedArgs('f')

					var textStream = fso.OpenTextFile(inFile)
					try {
						while (!textStream.AtEndOfStream) {
							var fileContent = textStream.ReadAll()
						}
					} finally {
						textStream.Close()
					}
				}

				var activeVoice = sapi.Voice
				if (namedArgs.Exists('v')) {
					var voiceName = namedArgs('v')

					voices = new Enumerator(sapi.GetVoices())
					while (!voices.atEnd()) {
						var item = voices.item()

						if (voiceName.toLowerCase() == item.GetDescription().slice(0, voiceName.length).toLowerCase()) {
							var activeVoice = item
							break
						}

						voices.moveNext()
					}
				}
				sapi.Voice = activeVoice

				var rate = 0
				if (namedArgs.Exists('r')) {
					rate = parseInt(namedArgs('r'))
					if (isNaN(rate)) { rate = 0 }
				}
				sapi.Rate = rate

				var speakFlags = 0
				var speakText = ''
				if (parameterSet == 'from_args') {
					speakFlags = 16

					var positionals = new Array(positionalArgs.length)
					for (var i = 0; i < positionalArgs.length; i++) {
						positionals[i] = positionalArgs.Item(i)
					}
					speakText = positionals.join(' ')
				} else if (parameterSet == 'from_file') {
					speakFlags = 8

					speakText = fileContent
				}

				var outFileStream = undefined
				if (namedArgs.Exists('o')) {
					var outFileStream = new ActiveXObject('SAPI.SpFileStream')
					// ref. https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ms720595%28v%3dvs.85%29
					outFileStream.Format.Type = 0
					outFileStream.Open(namedArgs('o'), 3)
					sapi.AudioOutputStream = outFileStream
					sapi.Speak(speakText, speakFlags)
					outFileStream.Close()
				} else (
					sapi.Speak(speakText, speakFlags)
				)
			]]>
		</script>
	</job>
</package>
