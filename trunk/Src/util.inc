

screenWidth		EQU	40
screenHeight	EQU	25
KEY_ESC			EQU	01h
KEY_ENTER		EQU	1ch
KEY_ALT			EQU	38h
KEY_UP			EQU	48h
KEY_DOWN		EQU	50h
KEY_LEFT		EQU	4bh
KEY_RIGHT		EQU	4dh

; exitCode
; no results
global ExitProgram: proc

; no params
; al=success/fail
global InitVideo: proc

;no params
;no results

global GameMenu: proc


; no params
; no results
global ShutdownVideo: proc


; no params
; no results
global ClearScreen: proc

;params :Screen name and buffer
;result :Screen in buffer and cf = 0 if successfull or cf = 1 if error 

global ReadScreen: proc


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


; no params
; no results
global InitializeRandomGenerator: proc

; maximum
; ax=random
global GenerateRandomNumber: proc
