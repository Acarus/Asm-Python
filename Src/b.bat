@echo off

tasm -m2 -v main.asm
if errorlevel 1 goto exit

tasm -m2 -v util.asm
if errorlevel 1 goto exit

tlink main.obj util.obj
if errorlevel 1 goto exit

echo Compiled successfully

:exit