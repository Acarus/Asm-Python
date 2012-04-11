.486
ideal
include "globals.inc"


dataseg

startingVideoMode	db 	?
startingCursorShapeC	dw	?

randSeed2		dd	0


codeseg

include "utils.inc"


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
	mov	dx , @@screenName
	mov	al , 0
	int	21h
	jc	@@error
	mov	si , ax
	mov	bx , ax
	mov	ah , 3fh
	mov	dx , @@buffer
	mov	cx , screenWidth * screenHeight * 2
	int	21h
	jc	@@error
	mov	ah , 3eh
	mov	bx , si   
	int	21h
	jc	@@error

@error:
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
	mov	dh , [@@x]
	mov	dl , [@@y]
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
	mov	dh , [@@x]
	mov	dl , [@@y]
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

; Params itemCount, char *itemPointers[]  ; !!! Support parameters
; Returns: al=index of menu item
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
	; !!! -------------- Retrun index of menu item selected
	ret         
endp


;#######################################################################################
;#######################################################################################
;#######################################################################################

; 
proc InitializeRandomGenerator

	push	es
	mov		es, 0040h
	mov		ax, [es:006ch]
	mov		dx, [es:006eh]
	mov		[word ptr randSeed2 + 0], ax
	mov		[word ptr randSeed2 + 2], dx
	pop		es

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
	mov	si, 43fdh                                              AAAA BBBB
	mul	si                                                        3 43fd
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
