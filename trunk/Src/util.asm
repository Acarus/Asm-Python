.486
ideal
include "globals.inc"

codeseg

include "utils.inc"


;#######################################################################################
;#######################################################################################
;#######################################################################################

; exitCode
; no results
proc ExitProgram
		 ARG:  @@code:byte         ;� �� ���� �� ������������� �����������.
	push ax				   ;�������� ���� �� ���
	mov al,[@@code]
	mov ah,4Ch
	int 21h
	pop ax
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; al=success/fail
proc InitVideo
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc ShutdownVideo
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc ClearScreen
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc HideCursor
	push cx
	push ax
	  mov ch,20h
	  mov ah,01h
	  int 10h
	pop ax
	pop cx
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc ShowCursor
	push cx
	push ax
	  mov cx,0607h
	  mov ah,01h
	  int 10h
	pop ax
	pop cx
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; x, y
; no results
proc SetCursorPos
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; x, y, char, color
; no results
proc OutputChar
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; x, y, zero-terminated-line, color
; no results
proc OutputString
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; pointerToImage (screenWidth*screenHeight), color
proc OutputScreenImage
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; ax=scan/ascii, cf=yes/no
proc IsCharPending
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; ax=scan/ascii
proc ReadInputChar
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; tickCount 
; no results
proc DelayExecution
		    ARG:		@@tick:word ;��� � ����������� ��� "???"
	push ax
	push cx
	push dx
		mov ah,86h
		mov dx,[@@tick]
		int 15h
	pop dx
	pop cx
	pop ax
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; maximum
; ax=random
proc GenerateRandomNumber
endp
