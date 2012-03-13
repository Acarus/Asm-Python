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
	ARG  @@Code:byte        
	push ax				   
	mov al,[@@Code]
	mov ah,4Ch
	int 21h
	pop ax
	ret
	
endp


;asm
;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; al=success/fail
proc InitVideo
	
		
		push	cx
    	mov  ah, 0
        mov  al, 1
        int  10h
		pop	cx
		
		ret
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

	mov	dh , 0
	mov	dl , 0

@@label:

	push	cx
        mov	ah , 02h
	mov	bh , 0
	int	10h
	mov	ah , 09h
	mov	bh , 0h
	mov	al , ' '
	mov	cx , 1h
	mov	bl , 7
	int 10h
	inc	dl
	push	dx

	mov	cl , 25
	xor	ax , ax
	mov	al , dl
	div	cl
	pop	dx
	cmp	ah , 0 
	je	@@NextLine
	jmp	@@label


@@NextLine:

	inc	dh
	xor	dl , dl
	cmp	dh , 40
	jne	@@label


@@exit:
pop	cx
ret
endp

proc ReadScreen
ARG @@screenName:word , @@buffer:word
push	cx

mov	ah , 3dh
mov	dx , @@screenName
mov	al , 0
int	21h
jc	@@error
mov	si , ax
mov	bx , ax
mov	ah , 3fh
mov	dx , @@buffer
mov	cx , 2000
int	21h
jc	@@error
mov	ah , 3eh
mov	bx , si   
int	21h
jc	@@error

@@exit:

pop	cx
clc	
ret

@@error:
stc
ret
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
	ret
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
	ret
	
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; x, y
; no results
proc SetCursorPos
ARG @@x:byte , @@y:byte 

	push	cx
	mov	ah , 02h
	mov	bh , 0
	mov	dh , [@@x]
	mov	dl , [@@y]
	int	10h
	pop	cx
	ret
	
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; x, y, char, color
; no results

;COLOR TABLE :::
;0 = black
;1 = blue
;2 = green
;4 = red
;6 = yellow
;7 = white
;8 = gray


proc OutputChar
ARG @@x:byte, @@y:byte , @@char:byte , @@color:byte 

	push	cx
	mov	ah , 02h
	mov	bh , 0
	mov	dh , [@@x]
	mov	dl , [@@y]
	int	10h
	mov	ah , 09h
	mov	bh , 0h
	mov	al , [@@char]
	mov	cx , 1h
	mov	bl , [@@color]
	int 10h
	pop	cx
	ret
	
endp





;#######################################################################################
;#######################################################################################
;#######################################################################################


; x, y, zero-terminated-line, color
; no results

proc OutputString
ARG	@@x:byte , @@y:byte , @@str:word , @@color:byte
                
	
	push	cx
	mov	si , @@str
	cmp	[si] , 0
	je	@@exit
	mov	dh , [@@y]
	mov	dl , [@@x]
	cmp     dl , 25
	ja	@@exit
	cmp	dh , 40
	ja	@@exit
	mov	ah , 02h
	mov	bh , 0
	int	10h
        mov	ah , 09h
	mov	bh , 0
	mov	al , [si]
	mov	cx , 1
	mov	bl , [@@color]
	int 10h
	
@@label:

	inc	si
	inc	dl
	cmp  [si] , 1
	jc	@@exit
	push dx
	xor	ax , ax
	mov	al , dl	
	mov	cl , 25
	div	cl
	pop	dx
	cmp	ah , 1
	jc	@@nextLine

@@WriteChar:

        mov	ah , 02h
	mov	bh , 0
	int	10h
	mov	ah , 09h
	mov	bh , 0
	mov	al , [si]
	mov	cx , 1
	mov	bl , [@@color]
	int 10h
	jmp	@@label
	
@@nextLine:

	xor	dl , dl
	inc	dh
	jmp	@@WriteChar

@@exit:

	pop	cx
	
	
ret
endp




;#######################################################################################
;#######################################################################################
;#######################################################################################

; pointerToImage (screenWidth*screenHeight), color

proc OutputScreenImage
ARG @@buffer:word
	
	
	push	cx
	mov	si , @@buffer
	mov	dh , 0
	mov	dl , 0

@@label:

        mov	ah , 02h
	mov	bh , 0
	int	10h
	mov	ah , 09h
	mov	bh , 0h
	mov	al , [si]
	mov	cx , 1h
	mov	bl , [si + 1]
	int 10h
	add	si , 2
	inc	dl
	push	dx

	mov	cl , 25
	xor	ax , ax
	mov	al , dl
	div	cl
	pop	dx
	cmp	ah , 0 
	je	@@NextLine
	jmp	@@label


@@NextLine:

	inc	dh
	xor	dl , dl
	cmp	dh , 40
	jne	@@label


@@exit:
	pop	cx
	

	ret
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

	
	push	cx
	xor ax , ax
	int 16h
	movzx ax , ah
	pop	cx
	
ret
endp

;#######################################################################################
;#######################################################################################
;#######################################################################################

; tickCount 
; no results
proc DelayExecution
	ARG		@@tick:word 

	push cx
	push dx
	mov ah,86h
	mov dx,[@@tick]
	int 15h
	pop dx
	pop cx
	ret
	
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; maximum
; ax=random
proc GenerateRandomNumber
endp
