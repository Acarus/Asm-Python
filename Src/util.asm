.486
ideal
include "globals.inc"


dataseg

startingVideoMode	db 	?
startingCursorShape	dw	?

randSeed2		dd	0


codeseg

include "util.inc"


;#######################################################################################
;#######################################################################################
;#######################################################################################


proc StringToInt
arg 	@@str:word
local   @@sum:word
	push	si
	push	di
	push	bx
	mov	bx , [@@str]
	xor	si , si
	xor	cx , cx
@@loop1:
	mov	ah , [bx + si]
	cmp	ah , 0
	je	@@next_step
	inc	cx
	inc	si
	jmp	@@loop1
@@next_step:
	mov	si , cx
	dec	si
	mov	di , 1
	xor	ax , ax
	mov	[@@sum] , ax
	
		
@@loop2:
	push	cx
	movzx	ax , [bx + si]
	sub	ax , 48
	mul	di
	mov	dx , [@@sum]
	add	ax , dx
	mov	[@@sum] , ax
	mov	ax , di
	mov	di , 10
	mul	di
	mov	di , ax
	dec	si
	pop	cx
	loop	@@loop2
	mov	ax , [@@sum]
	pop	bx
	pop	di
	pop	si
		ret
			
endp

;#######################################################################################
;#######################################################################################
;#######################################################################################

proc	intToString
ARG	@@number:word , @@mass:word
	push	si
	push	di
	push	bx
	mov	ax , [@@number]
	mov	di , 0
	mov	bx , 10

@@first_step:

	xor	dx , dx
	div	bx
	add	dl , 30h
	mov	[byte ptr @@mass + di],dl
	inc	di
	cmp	ax , 1
	jc	@@next_step
	jmp	@@first_step

@@next_step:

	cmp	di , 1
        jz	@@oneParam
	push	di
	mov	cx , di
	shr	cx , 1
	mov	si , 0
	dec     di

	

@@for:
	mov	bl , [byte ptr @@mass + si]
	mov	bh , [byte ptr @@mass + di]
	mov	[byte ptr @@mass + si] , bh
	mov	[byte ptr @@mass + di] , bl
	dec	di
	inc	si
	cmp	cx , si
	je	@@for
	jmp	@@moreParam

@@moreParam:

	pop	di
	mov	[byte ptr @@mass + di] , '$'
	jmp	@@exit


 @@oneParam:
	mov	[byte ptr @@mass + di] , '$'


 @@exit:
	pop	bx
	pop	di
	pop	si
	ret
	
endp



;#######################################################################################
;#######################################################################################
;#######################################################################################

; exitCode
; no results
proc ExitProgram
ARG  @@Code:byte        
	mov	al,[@@Code]
	mov	ah,4Ch
	int	21h
	ret
endp

;#######################################################################################
;#######################################################################################
;#######################################################################################
proc	Sleep
ARG  @@time:word
local	@@seconds:byte , @@hundseconds:byte
mov		ah , 2ch
int		21h
mov		ax , [@@time]
mov		ch , 100
div		ch
add		dl , ah
add		dh , al
mov		[@@seconds] , dh
mov		[@@hundseconds] , dl
mov		bh , [@@seconds]
mov		bl , [@@hundseconds]
@@cicl:
push	bx
mov		ah , 2ch
int		21h
pop		bx
cmp		dh , bh
ja		@@exit
cmp		dl , bl
jb		@@cicl
@@exit:
ret
endp

;asm
;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; al=success/fail
proc InitVideo
	
	PUSH_PROC_REGS
    	
	; Save initial video mode into starting_video_mode
	mov	ax, 0f00h
	int	10h
	mov 	[startingVideoMode],al
	mov	ax, 0001h
        int	10h
	POP_PROC_REGS	
		
	ret
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc ShutdownVideo


	; restore initial video mode from starting_video_mode
	PUSH_PROC_REGS
	mov 	al, [startingVideoMode]
	mov	ah, 00h
        int	10h
	POP_PROC_REGS
	ret
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc ClearScreen

	PUSH_PROC_REGS

	; !!! This can be implemented with one interrupt call with CX=...

	mov	dh , 0
	mov	dl , 0

@@label:

	
        mov	ah , 02h
	mov	bh , 0
	int	10h
	mov	ah , 09h
	mov	bh , 0h
	mov	al , ' '
			;	mov	cx , 1h
	mov	cx , screenWidth * screenHeight
	mov	bl , 7
	int 	10h
			;	inc	dl
			;
			;	cmp	dl, screenWidth
			;	jne	@@label
			;
			;@@NextLine:
			;
			;	inc	dh
			;	xor	dl , dl
			;	cmp	dh , screenHeight
			;	jne	@@label
	

	POP_PROC_REGS
	ret
endp

proc ReadScreen
ARG @@screenName:word , @@buffer:word

	PUSH_PROC_REGS

	mov	ah , 3dh
	mov	dx , [@@screenName]
	mov	al , 0
	int	21h
	jc	@@error
	mov	si , ax
	mov	bx , ax
	mov	ah , 3fh
	mov	dx , [@@buffer]
	mov	cx , screenWidth * screenHeight * 2
	int	21h
	jc	@@error
	mov	ah , 3eh
	mov	bx , si   
	int	21h
	jc	@@error

@@error:
	POP_PROC_REGS
	ret

endp




;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc HideCursor
	PUSH_PROC_REGS
	
	; Save cursor shape in starting_cursor_shape(C/D)

	  mov ah,03h
	  mov bh,00h
	  int 10h
	  mov [startingCursorShape],cx
	  mov cx,2000h
	  mov ah,01h
	  int 10h

	POP_PROC_REGS
	ret
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; no results
proc ShowCursor
	PUSH_PROC_REGS

	  mov cx,[startingCursorShape]
	  mov ah,01h
	  int 10h

	POP_PROC_REGS
	ret
	
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; x, y
; no results
proc SetCursorPos
ARG @@x:byte , @@y:byte 
	PUSH_PROC_REGS

	mov	ah , 02h
	mov	bh , 0
	mov	dh , [@@y]
	mov	dl , [@@x]
	int	10h

	POP_PROC_REGS
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
	PUSH_PROC_REGS

	mov	ah , 02h
	mov	bh , 0
	mov	dh , [@@y]
	mov	dl , [@@x]
	int	10h
	mov	ah , 09h
	mov	bh , 0h
	mov	al , [@@char]
	mov	cx , 1h
	mov	bl , [@@color]
	int	10h

	POP_PROC_REGS
	ret
	
endp





;#######################################################################################
;#######################################################################################
;#######################################################################################


; x, y, zero-terminated-line, color
; no results


proc OutputString
ARG	@@x:byte , @@y:byte , @@str:word , @@color:byte
	
	PUSH_PROC_REGS

	; This can be made with a singe callto int 10h fn 1300

	mov	si , [@@str]
	cmp	[byte ptr si] , 0
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
	int 	10h
	
@@label:

	inc	si
	inc	dl
	mov	bh , [si]
	cmp  	bh , 1
	jc	@@exit
	cmp 	dl, screenWidth
	je	@@nextLine

@@WriteChar:

        mov	ah , 02h
	mov	bh , 0
	int	10h
	mov	ah , 09h
	mov	bh , 0
	mov	al , [si]
	mov	cx , 1
	mov	bl , [@@color]
	int 	10h
	jmp	@@label
	
@@nextLine:

	xor	dl , dl
	inc	dh     ;  DH may exceed the screen line count!!!
	jmp	@@WriteChar

@@exit:
	POP_PROC_REGS
	ret
endp	





;#######################################################################################
;#######################################################################################
;#######################################################################################

; pointerToImage (screenWidth*screenHeight), color

proc OutputScreenImage
ARG @@buffer:word
	PUSH_PROC_REGS

	;Can be implemented with one call to int 10 fn 1303	

	mov	si , [@@buffer]
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
	int	10h
	add	si , 2
	inc	dl
	cmp	dl, screenWidth
	jne	@@label

@@NextLine:

	inc	dh
	xor	dl , dl
	cmp	dh , screenHeight
	jne	@@label


@@exit:
	POP_PROC_REGS
	ret
endp



;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; ax=scan/ascii, cf=yes/no
proc   IsCharPending 
	PUSH_PROC_REGS

	mov	ah , 11h
	int	16h
	jnz	@@yes
	clc
	jmp	@@exit
@@yes:
	mov	ah , 10h
	int	16h
	stc
@@exit:

	POP_PROC_REGS
	ret	

endp



;#######################################################################################
;#######################################################################################
;#######################################################################################

; no params
; ax=scan/ascii
proc ReadInputChar
	PUSH_PROC_REGS

	xor ax , ax
	int 16h
	
	POP_PROC_REGS
	ret
endp

;#######################################################################################
;#######################################################################################
;#######################################################################################

; tickCount 
; no results
proc DelayExecution
	ARG		@@tick:word 
	push	es

	mov		ax, 00040 
	mov		es, ax
	mov		cx, [@@tick]
	mov		ax, [es:0006ch]

@@loop:
	mov		dx, ax

@@wait_change:
	mov		ax, [es:0006ch]
	cmp		ax, dx
	je		@@wait_change
	sub		cx, 1
	jnc		@@loop

	pop		es
	ret
	
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

proc	GameMenu
ARG		@@argc:word , @@argv:word , @@spos:word
local	@@active:byte

SELECT_CHAR = 16
MENU_X = 8
SELECT_X = MENU_X-2
	mov	bx , [@@argv]
	mov	dx , [@@argc]
	xor	di , di
	xor 	si , si
	mov	ax , bx
	mov	cx , [@@spos]
@@someLabel1:

	push	cx
	push	dx
	call	outputString , MENU_X , cx , ax , 7
	pop	dx
	pop	cx
	
@@for:
	mov	ah , [bx + si]
	inc	si
	cmp	ah , 0
	jne	@@for
	mov	ax , bx
	add	ax , si
	add	cx , 2
	dec	dx
	cmp	dx , 0
	jne	@@someLabel1
	
	
	mov	al , 1
	mov	[@@active] , al        
	
	mov	ax , [@@spos]
	call	outputChar , SELECT_X, ax , SELECT_CHAR , 5
	
@@q:
	
	call	ReadInputChar
	cmp	ah , KEY_UP
	je	@@k_up	
	cmp	ah , KEY_DOWN
	je	@@k_down
	cmp	ah , KEY_ENTER
	je	@@k_enter
	cmp	ah , KEY_ESC
	je	@@back
	jmp	@@q
	
@@k_up:
	
	mov	al , [@@active]
	cmp	al , 1
	je	@@k_up_2
	movzx	cx , al
	shl	cx , 1
	mov	ax , [@@spos]
	sub	ax , 4
	add	cx , ax	
	push	cx
	call	outputChar , SELECT_X , cx , SELECT_CHAR , 5
	pop	cx
	add 	cx , 2
	call	outputChar , SELECT_X , cx , ' ' , 7	
	mov	al , [@@active]
	dec	al
	mov	[@@active] , al
	jmp	@@q
	
	
@@k_up_2:
	mov	ax , [@@spos]
	call	outputChar , SELECT_X , ax , ' ' , 7

	mov	cx , [@@argc]
	mov	[@@active] , cl

	dec	cx	
	shl	cx , 1
	add	cx , [@@spos]
	call	outputChar , SELECT_X , cx , SELECT_CHAR , 5
	jmp	@@q
	
@@k_down:
	mov	bx , [@@argc]
	mov	al , [@@active]
	cmp	bl , al
	je 	@@k_down_2
	mov	al , [@@active]
	inc	al
	mov	[@@active] , al
	movzx	cx , al                             
	dec	cx
	shl	cx ,1
	mov	ax ,[@@spos]
	add	cx , ax
	push	cx
	call	outputChar , SELECT_X , cx , 16 , 5
	pop	cx
	sub	cx , 2
	call	outputChar , SELECT_X , cx , ' ' , 7

	jmp		@@q
	
@@k_down_2:
	mov	al , 1
	mov	[@@active] , al
	
	mov     cx , [@@spos]
	call	outputChar , SELECT_X , cx , 16 , 5
	mov	ax , [@@argc]
	shl	ax , 1
	add	ax , SELECT_X
	call	outputChar , SELECT_X , ax , ' ' , 7
	jmp	@@q
	
@@k_enter:
	call	ClearScreen
	xor	ax , ax
	mov	al , [@@active]  
	ret
	@@back:
	mov	ax , 0ffffh     
	ret
endp



;#######################################################################################
;#######################################################################################
;#######################################################################################

; 
proc InitializeRandomGenerator

	push		es
	mov		ax, 0040h
	mov		es, ax
	mov		ax, [es:006ch]
	mov		dx, [es:006eh]
	mov		[word ptr randSeed2 + 0], ax
	mov		[word ptr randSeed2 + 2], dx
	pop		es
	ret
endp

;#######################################################################################
;#######################################################################################
;#######################################################################################

; maximum
; ax=random
proc GenerateRandomNumber
ARG	@@max:word

;        _ptiddata ptd = _getptd();
;                                                                       
;        return( ((ptd->_holdrand = ptd->_holdrand * 0x343fd            
;            + 0x269EC3) >> 16) & 0x7fff );                             

;	srand(0);
;	((rand() * 2 * max) >> 16)

	push	bx
	push	si
	mov	ax, [word ptr randSeed2]
	mov	si, 43fdh                                             
	mul	si                                                        
	mov	cx, dx
	mov	bx, ax
	mov	ax, [word ptr randSeed2+2]
	mul	si
	add	cx, ax
	mov	ax, [word ptr randSeed2]
	mov	si, 3h
	mul	si
	add	cx, ax
	add	bx, 9ec3h
	adc	cx, 26h
	mov	[word ptr randSeed2], bx
	mov	ax, cx
	mov	[word ptr randSeed2], cx
	shl	ax, 1
	mul	[@@max]
	mov	ax, dx
	pop	si
	pop	bx
	ret
endp


end
