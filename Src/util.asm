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

	push	cx
	mov	dh , 0
	mov	dl , 0

@@label:

	
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

	mov	cl , screenWidth
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
	cmp	dh , screenHeight
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
	cmp     dl , screenHeight
	ja	@@exit
	cmp	dh , screenWidth
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
	mov	bh , [si]
	cmp  bh , 1
	jc	@@exit
	push dx
	xor	ax , ax
	mov	al , dl	
	mov	cl , screenHeight
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

	mov	cl , screenWidth
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
	cmp	dh , screenHeight
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
proc   IsCharPending 
push	cx
mov	ah , 11h
int	16h
jnz	@@yes
clc
@@exit:
pop	cx
ret	
@@yes:
stc
jmp	@@exit
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


proc	GameMenu
local	@@active:byte   
mov	al , 1
mov	[@@active] , al                                       
@@q:

call	ReadInputChar
                          

cmp	ah , key_down
je	@@k_down
cmp	ah , key_up
je	@@k_up
cmp	ah , key_enter
je	@@k_enter
jmp	@@q
	
@@k_up:

	mov	al , [@@active]
   	cmp	al , 1 
   	je	@@start_game_u
	mov	al , [@@active]
	cmp	al , 2
	je	@@select_level_u
	mov	al , [@@active]
	cmp	al , 3 
	je	@@exit_game_u

@@start_game_u:

	call	outputchar , 8 , 11 , ' ' , 7 
	call	outputchar , 12 , 11 , '' , 4
	mov	[@@active] , 3
	jmp	@@q	

@@select_level_u:

	
	call	outputchar , 10 , 11 , ' ' , 7
	call	outputchar , 8 , 11 , '' , 4
	mov	[@@active] , 1
	jmp	@@q

@@exit_game_u:

        call	outputchar , 12 , 11 , ' ' , 7
	call	outputchar , 10 , 11 , '' , 4
	mov	[@@active] , 2
	jmp	@@q

	

@@k_down:
	
	mov	al , [@@active]
   	cmp	al , 1 
   	je	@@start_game_d
	mov	al , [@@active]
	cmp	al , 2
	je	@@select_level_d
	mov	al , [@@active]
	cmp	al , 3 
	je	@@exit_game_d

@@start_game_d:

	call	outputchar , 8 , 11, ' ' , 7 
	call	outputchar , 10 , 11 , '' , 4
	mov	[@@active] , 2
	jmp	@@q	

@@select_level_d:

	
	call	outputchar , 10 , 11 , ' ' , 7
	call	outputchar , 12 , 11 , '' , 4
	mov	[@@active] , 3
	jmp	@@q

@@exit_game_d:

        call	outputchar , 12 , 11 , ' ' , 7
	call	outputchar , 8 , 11 , '' , 4
	mov	[@@active] , 1
	jmp	@@q

@@k_enter:
	
	mov	al , [@@active]
	cmp	al , 3
	je	@@exit
	jmp	@@q

@@exit:
         
call	ClearScreen
call	ExitProgram
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; maximum
; ax=random
proc GenerateRandomNumber
ARG	@@max:word
push 	cx
mov	bx , [@@max]
in 	al,041h
mov	ah , al
in	al,042h
@@label1:
cmp	ax , bx
ja	@@dil
pop	cx
ret
@@dil:
shr	ax , 1
jmp	@@label1
endp
