.486
ideal
include "globals.inc"

stack 256

include "util.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


LEVEL_COUNT	EQU	9
RABBITS_PER_LEVEL EQU	16
GROWTH_PER_RABBIT EQU	1

TARGET_SYMBOL	EQU	0cfh
TARGET_ATTR	EQU	7

HEAD_SYMBOL	EQU	'@'
HEAD_ATTR	EQU	7
BODY_SYMBOL	EQU	'O'
BODY_ATTR	EQU	7

WALL_SYMBOL	EQU	'#'

EMPTY_SYMBOL	EQU	' '
EMPTY_ATTR	EQU	7

START_X		EQU	screenWidth / 2
START_Y		EQU	screenHeight - 1


macro render
	call	OutputScreenImage , offset buf
endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


dataseg

currentLevel	db	0		; Contains current game level
rabitsRemainder	db	0		; Contains number of rabbits to be eaten until level increment
growthRemainder	db	0		; Contains how many steps python has to grow yet

headIndex	dw	0		; Index of HEAD_SYMBOL in array
tailIndex	dw	0		; Index of tail in array

motionDelta	ScreenCoord <0, -1>	; Direction of motion

gover1          db 'Game Over',0
gover2          db 'Press enter to restart',0
gover3          db 'Press escape to @@exit the menu',0
targ            db      0
msg                     db      'You eated the TARGET_SYMBOL !',0
randSeed2 dd    0
paramString db 'Start Game',0,'Option',0,'Select level',0,'@@exit',0
levelName       db      'levels\\first.lv',0
buf     db       2000 dup (' ') , '$'
python  db      2000 dup (?)
fileName db     'menu.sc',0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

udataseg

rabbitCoords	ScreenCoord ?

pythonCoords	ScreenCoord (screenWidth * screenHeight) dup (?)

; Contents of screen with attributes
screenBuffer	db	2 * screenWidth * screenHeight dup (?)


levelDelays	dw	LEVEL_COUNT dup (?)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

codeseg


proc	get_pos 
ARG 	@@x:byte , @@y:byte 
	mov		ax , screenWidth
	mov		ch , [@@y]
	dec		ch
	mul		ch
	xor		bx , bx
	mov		bl , [@@x]
	inc		bl
	add		ax , bx
	shl		ax , 1
	sub		ax , 4
	mov		si , ax
	ret
endp




; pos = ((y - 1) * width + x) * 2 - 2
proc	StartGame
ARG		@@levelSpeed:byte , @@levelScreen:word , @@start_X:byte , @@start_Y:byte
local	@@head:word , @@tail:word , @@direction:byte , @@size:byte , @@help:byte 
@@start_game_l:
	mov		[@@size] , 2
	mov		ax, [@@levelScreen]
	call	ReadScreen , ax , offset buf
	call	OutputScreenImage , offset buf
	mov		ah , [@@start_Y]
	mov		al , [@@start_X]
	mov		[@@head] , ax
	movzx	bx , al
	movzx	cx , ah
	push	bx
	push	cx
	call	outputChar , bx , cx , HEAD_SYMBOL , HEAD_ATTR
	pop		cx
	pop		bx
	mov		ax , screenWidth
	dec		cx
	mul		cx
	add		ax , bx
	shl		ax , 1
	mov		si , ax
	mov		[buf + si - 2] , HEAD_SYMBOL
	mov		[buf + si - 1] , HEAD_ATTR	
	mov		ax , [@@head]
	inc		ah
	movzx	bx , al
	movzx	cx , ah
	push	bx
	push	cx
	call	outputChar , bx , cx , BODY_SYMBOL , BODY_ATTR
	pop		cx
	pop		bx
	mov		ax , screenWidth
	dec		cx
	mul		cx
	add		ax , bx
	shl		ax , 1
	mov		si , ax
	mov		[buf + si - 2] , BODY_SYMBOL
	mov		[buf + si - 1] , BODY_ATTR
	mov		[@@tail] , 2
	mov		ax , [@@head]
	inc		ah
	mov		[word ptr python] , ax
	inc		ah
	mov		[word ptr python + 2] , ax 	
	mov		ax , [@@head]
	add		ah , 2
	movzx	bx , al
	movzx	cx , ah
	push	bx
	push	cx
	call	outputChar , bx , cx , BODY_SYMBOL , BODY_ATTR
	pop		cx
	pop		bx
	mov		ax , screenWidth
	dec		cx
	mul		cx
	add		ax , bx
	shl		ax , 1
	mov		si , ax
	mov		[buf + si - 2] , BODY_SYMBOL
	mov		[buf + si - 1] , BODY_ATTR
; 1 - up
; 2 - down
; 3 - left
; 4 - right
	mov		[@@direction] , 1
@@for:
	
	mov	al , [targ]
	cmp	al , 1
	je	@@for2
	mov	si , 0
	mov bx , offset buf
	xor	cx , cx
@@for_label1:
	add	si , 2
	mov	al , [bx + si]
	cmp	al , 20h 
	jne	@@for_label1
	inc	cx
	cmp	si , 2000
	jb	@@for_label1
	call	GenerateRandomNumber , cx
	xor	cx , cx
	xor	si , si
	mov	bx , offset buf
@@for_label2:
	add	si , 2
	mov	al , [bx + si]
	cmp	al , 20h
	jne	@@for_label2
	inc	cx
	cmp	cx , ax
	jne	@@for_label2
	mov	[byte ptr bx + si] , TARGET_SYMBOL
	mov	[byte ptr bx + si + 1] , TARGET_ATTR
	render
	mov	al , 1
	mov	[targ] , al
@@for2:
	call	Sleep  , 15
	call	IsCharPending
	jz	@@waiting 
	mov	[@@help] , ah
@@from_waiting:
	mov	ax , [@@head]
	movzx	bx , al
	movzx	cx , ah
	call	get_pos, bx , cx
	mov	[buf + si ] , BODY_SYMBOL
	mov	[buf + si + 1] , BODY_ATTR
	mov	si , [@@tail]
	mov	ax , [@@head]
	mov	bx , [word ptr python + si]
	mov	[word ptr python + si] , ax
	movzx	ax , bl
	movzx	cx , bh
	call	get_pos , ax ,cx
	mov		[buf + si] , ' ' 
	mov		[buf + si + 1] , 7	

	mov		ah , [@@help]
	cmp		ah , KEY_UP
	je		@up
	cmp		ah , KEY_DOWN
	je		@down
	cmp		ah , KEY_LEFT
	je		@left
	cmp		ah , KEY_RIGHT
	je		@@right
	cmp		ah , KEY_ESC
	je		@@fast_exit
@@for3:

	mov	[@@head] , ax
	movzx	bx , al
	movzx	cx , ah
	call	get_pos , bx ,cx
	mov	[buf + si] , HEAD_SYMBOL
	mov	[buf + si + 1] , HEAD_ATTR
	render
	mov		ax , [@@tail]
	movzx 	bx , [@@size]
	shl	bx , 1
	add	ax , 2
	cmp	bx , ax
	jne	@@for2
	xor	ax , ax
	mov	[@@tail] , ax
	jmp	@@for
	
@up:
	mov	ah , 1
	mov	[@@direction] , ah
	mov	ax , [@@head]
	dec	ah
	push 	ax
	movzx 	bx , al
	movzx 	cx , ah
	call	get_pos , bx , cx
	mov		ah , [buf + si]
	cmp		ah , WALL_SYMBOL
	je		@@exit
	cmp		ah , BODY_SYMBOL
	je		@@exit
	cmp		ah , TARGET_SYMBOL
	je		@@eat
	pop		ax
	cmp	ah , 0
	jne	@@for3
	mov	ah , screenHeight
	jmp	@@for3
	
@down:
	mov	ah , 2
	mov	[@@direction] , ah
	mov	ax , [@@head]
	inc	ah
	push 	ax
	movzx 	bx , al
	movzx 	cx , ah
	call	get_pos , bx , cx
	mov		ah , [buf + si]
	cmp		ah , WALL_SYMBOL
	je		@@exit
	cmp		ah , BODY_SYMBOL
	je		@@exit
	cmp		ah , TARGET_SYMBOL
	je		@@eat
	pop		ax
	cmp	ah , screenHeight
	jne	@@for3
	mov	ah , 0
	jmp	@@for3
	
@left:
	mov	ah , 3
	mov	[@@direction] , ah
	mov		ax , [@@head]
	dec		al
	push 	ax
	movzx 	bx , al
	movzx 	cx , ah
	call	get_pos , bx , cx
	mov		ah , [buf + si]
	cmp		ah , WALL_SYMBOL
	je		@@exit
	cmp		ah , BODY_SYMBOL
	je		@@exit
	cmp		ah , TARGET_SYMBOL
	je		@@eat
	pop		ax
	cmp		al , 0
	jne		@@for3
	mov		al , screenWidth
	jmp		@@for3
	
@@right:
	mov	ah , 4
	mov	[@@direction] , ah
	mov	ax , [@@head]
	inc	al
	push 	ax
	movzx 	bx , al
	movzx 	cx , ah
	call	get_pos , bx , cx
	mov		ah , [buf + si]
	cmp		ah , WALL_SYMBOL
	je		@@exit
	cmp		ah , BODY_SYMBOL
	je		@@exit
	cmp		ah , TARGET_SYMBOL
	je		@@eat
	pop		ax
	cmp	al , screenWidth
	jne	@@for3
	mov	al , 0
	jmp	@@for3
	
@@eat:
	mov	al , 0
	mov	[targ] , al
	pop	ax
	jmp	@@for3
	
@@waiting:


	
	mov	ah , [@@direction]
	cmp	ah , 1
	je	@@d_up
	cmp	ah , 2
	je	@@d_down
	cmp	ah , 3
	je	@@d_left
	cmp	ah , 4
	jne	@@for
	mov	ah , KEY_RIGHT
	mov	[@@help] , ah
	jmp	@@from_waiting
	
@@d_up:
	mov	ah , KEY_UP
	mov	[@@help] , ah
	jmp	@@from_waiting
	
@@d_down:	
	mov	ah , KEY_DOWN
	mov	[@@help] , ah
	jmp	@@from_waiting
	
@@d_left:	
	mov	ah , KEY_LEFT
	mov	[@@help] , ah
	jmp	@@from_waiting
	
@@exit:
	call	outputString , 15 , 12 , offset gover1 , 4
	call	outputString , 0 , 0 , offset gover2 , 4
	call	outputString , 0 , 1 , offset gover3 , 4
@@cicl:
	call	IsCharPending
	cmp		ah , KEY_ESC
	je		@@fast_exit
	cmp		ah , KEY_ENTER
	jne		@@cicl
	call    ReadScreen  , offset fileName , offset buf
	call	OutputScreenImage , offset buf
	jmp		@@start_game_l

@@fast_exit:
	ret

endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	mov	ax , @data
	mov	ds , ax
 
	call	InitializeRandomGenerator
	call	initVideo
	call	HideCursor
@@again:
	call    ReadScreen  , offset fileName , offset buf
	call	OutputScreenImage , offset buf
	call	GameMenu , 4 , offset paramString
	cmp	ax , 1
	je	@@start
	cmp	ax , 4
	je	@@exit
	jmp	@@again
@@start:
	call	StartGame , 3000 ,offset levelName , 15 , 10
	jmp	@@again

@@exit:
	call	ClearScreen
	call	ShutdownVideo
	call	ExitProgram


end	start
