

screenWidth	EQU	40
screenHeight	EQU	25

; exitCode
; no results
global ExitProgram: proc

; no params
; al=success/fail
global InitVideo: proc


; no params
; no results
global ShutdownVideo: proc


; no params
; no results
global ClearScreen: proc


; no params
; no results
global HideCursor: proc


; no params
; no results
global ShowCursor: proc


; x, y
; no results
global SetCursorPos: proc


; x, y, char, color
; no results
global OutputChar: proc


; x, y, zero-terminated-line, color
; no results
global OutputString: proc

; pointerToImage (screenWidth*screenHeight), color
global OutputScreenImage: proc


; no params
; ax=scan/ascii, cf=yes/no
global IsCharPending: proc


; no params
; ax=scan/ascii
global ReadInputChar: proc


; tickCount 
; no results
global DelayExecution: proc


; maximum
; ax=random
global GenerateRandomNumber: proc
