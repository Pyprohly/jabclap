@echo off
setlocal

set "parse_mode=cmd"
REM set "parse_mode=unix"

set "parser=%~dp0\..\src\parser-%parse_mode%.js"
set "filemask=%parse_mode%*.Tests.bat"

if not exist "%parser%" (
	>&2 echo The parser file could not be found
	exit /b 1
)

for /f "delims=" %%I in (' dir /a:-d /b "%filemask%" ') do (
	echo Describing %%I
	call "%%~I"
)
