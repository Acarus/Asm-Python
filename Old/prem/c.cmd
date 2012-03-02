@echo off

for %%a in (*.asm) do (
  ..\tasm3\tasm /zi /m2 /l /c %%a
  if errorlevel 1 goto :exit
)

..\tasm3\tlink /v prem.obj util.obj

:exit

