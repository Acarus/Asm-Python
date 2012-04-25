@echo off

tasm -m2 -v main.asm >errors.txt
if errorlevel 1 goto exit

tasm -m2 -v util.asm >errors.txt
if errorlevel 1 goto exit

tlink -v main.obj util.obj >errors.txt
if errorlevel 1 goto exit

echo Compiled successfully
set /p x=debug?
if %x%==y start td main.exe

:exit