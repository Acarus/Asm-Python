@echo off

U:\asm-python\tasm3\tasm -m2 -v main.asm
if errorlevel 1 goto exit

U:\asm-python\tasm3\tasm -m2 -v util.asm
if errorlevel 1 goto exit

U:\asm-python\tasm3\tlink -v main.obj util.obj
if errorlevel 1 goto exit

echo Compiled successfully
set /p x=debug?
if %x%==y start U:\asm-python\tasm3\td main.exe

:exit