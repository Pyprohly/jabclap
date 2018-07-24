@echo off
setlocal

set "parser=%~dp0\..\src\parser-cmd.js"
set "filemask=cmd*.Tests.bat"

if not exist "%parser%" (
	>&2 echo The parser file could not be found
	exit /b 1
)

for /f "delims=" %%I in (' dir /a:-d /b "%filemask%" ') do (
	echo Describing %%I
	call "%%~I"
)
