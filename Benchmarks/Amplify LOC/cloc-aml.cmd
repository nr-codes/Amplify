@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "VER=2.08"
set "CLOC=cloc-%VER%.exe"
set "URL=https://github.com/AlDanial/cloc/releases/download/v%VER%/%CLOC%"

set "INCL1=--by-file-by-lang"
set "INCL2=--read-lang-def=ampl_definitions.txt %INCL1%"
set "OUT=--out=."


REM get cloc
if not exist "%CLOC%" (
  curl.exe -o "%CLOC%" -L "%URL%"
)

if exist "%CLOC%" (
  REM count lines of code
  "%CLOC%" %INCL2% %OUT%\amplify.txt amplify.mod
) else (
  echo %~n0: could not download cloc, no output files generated.
)
