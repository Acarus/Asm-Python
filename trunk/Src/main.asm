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
INITIAL_GROWTH 	EQU	2
GROWTH_PER_RABBIT EQU	1

TARGET_SYMBOL	EQU	0cfh
TARGET_ATTR	EQU	7

HEAD_SYMBOL	EQU	'@'
HEAD_ATTR	EQU	7
BODY_SYMBOL	EQU	'O'
BODY_ATTR	EQU	7

WALL_SYMBOL	EQU	'#'
WALL		EQU 	WALL_SYMBOL

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

editFile	db	'edit.sc',0
max			db  3		
inputBuf	db	5 dup (?)
testf		db  '125',0
sX			db 'Enter start x :',0
sy			db 'Enter start y :',0
enterSp		db	'Enter Speed : ',0
showSize	db 'Size:   ' , 0
info		db	'LEVEL EDITOR (c) 2012 LMPL',0
enterX		db	'Enter start x pos :',0
enterY		db 'Enter start y pos :',0
enterS		db	'Enter level speed :',0
gover1		db 'Game Over',0	
gover2		db 'Press enter to restart',0	
gover3		db 'Press escape to exit the menu',0	
targ		db	0
msg			db	'You eated the TARGET_CHAR !',0
randSeed2 dd	0
paramString db 'Start Game',0,'Select level',0,'Edit level',0,'Exit',0
levelName	db	'levels\\level1.lv',0
levelInc	db	'levels\\level1.inc',0
levelLIsCharPendingt	db	'Level 1',0,'Level 2',0,'Level 3',0,'Level 4',0
buf	db	 2 * screenWidth * screenHeight dup (' ') , '$'      
python	db	2 * screenWidth * screenHeight dup (?)
fileName db	'menu.sc',0
help	db	3 dup (?)





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


proc outputToBuf
Arg @@X: byte, @@Y: byte, @@SYM: byte, @@Attr: byte
	push		si
	call		outputChar, [@@x], [@@y], [@@sym], [@@attr]
	mov		ax , screenWidth
	movzx		cx , [@@y]
	dec		cx
	mul		cx
	add		ax , [@@x]
	shl		ax , 1
	mov		si , ax
	mov		[byte ptr buf + si - 2] , HEAD_SYMBOL
	mov		[byte ptr buf + si - 1] , HEAD_ATTR	
	pop		si
	ret
endp



; pos = ((y - 1) * width + x) * 2 - 2
proc	StartGame
ARG		@@levelSpeed:byte , @@levelScreen:word , @@start_X:byte , @@start_Y:byte
local	@@head:word , @@tail:word , @@direction:byte , @@size:byte , @@help:byte 
@@start_game_l:
	mov		[@@size] , INITIAL_GROWTH
	mov		ax, [@@levelScreen]
	mov		ah , [@@start_Y]
	mov		al , [@@start_X]
	mov		[@@head] , ax

	call	ReadScreen , ax , offset buf
	call	OutputScreenImage , offset buf
	call	outputToBuf , [@@start_X] , [@@start_Y] , HEAD_SYMBOL , HEAD_ATTR


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
	je		@@up
	cmp		ah , KEY_DOWN
	je		@@down
	cmp		ah , KEY_LEFT
	je		@@left
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
	
@@up:
	mov	ah , 1
	mov	[@@direction] , ah
	mov	ax , [@@head]
	dec	ah
	push 	ax
	movzx 	bx , al
	movzx 	cx , ah
	call	get_pos , bx , cx
	mov		ah , [buf + si]
	cmp		ah , TARGET_SYMBOL
	je		@@eat
	cmp		ah , ' '
	jne		@@exit
	pop		ax
	cmp	ah , 0
	jne	@@for3
	mov	ah , screenHeight
	jmp	@@for3
	
@@down:
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
	
@@left:
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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


proc	SelectLevel
	xor	si , si
	mov	cx , size buf
@@loop1:
	mov	[buf + si] , 20h
	mov	[buf + si + 1] , 7
	add	si , 2
	loop	@@loop1
render
	call	GameMenu , 4 , offset levelLIsCharPendingt , 8
	cmp	ax , 1
	je	@@1
	cmp	ax , 2
	je	@@2
	cmp	ax , 3
	je	@@3
	mov	ah , 34h
	mov	[levelName + 13] , ah
	mov	[levelInc + 13] , ah
	jmp	@@exit
@@1:
	mov	ah , 31h
	mov	[levelName + 13] , ah
	mov	[levelInc + 13] , ah
	jmp	@@exit
@@2:
	mov	ah , 32h
	mov	[levelName + 13] , ah
	mov	[levelInc + 13] , ah
	jmp	@@exit
@@3:
	mov	ah , 33h
	mov	[levelName + 13] , ah
	mov	[levelInc + 13] , ah
@@exit:
	
	ret
endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc EditLevel
	local @@pos:word , @@color:byte , @@wall_char:byte , @@speed:byte , @@cords:word
	call    ReadScreen  , offset fileName , offset buf 
	render
	call	GameMenu , 4 , offset levelLIsCharPendingt , 8
	cmp		ax , 0ffffh
	je		@@exit
	cmp		ax , 1
	je		@@1
	cmp		ax , 2
	je		@@2
	cmp		ax , 3
	je		@@3
	mov		ah , 34h
	mov		[levelName + 13] , ah
	mov		[levelInc + 13] , ah
	jmp		@@next
@@1:
	mov		ah , 31h
	mov		[levelName + 13] , ah
	mov		[levelInc + 13] , ah
	jmp		@@next
	@@2:
	mov		ah , 32h
	mov		[levelName + 13] , ah
	mov		[levelInc + 13] , ah
	jmp		@@next
	@@3:
	mov		ah , 33h
	mov		[levelName + 13] , ah
	mov		[levelInc + 13] , ah
	@@next:
	call    ReadScreen  , offset editFile , offset buf 
	render
	call	outputString , 0,  0 , offset enterSp , 4
	mov cx,03h 
	mov ah,01h
	int 10h
	call	SetCursorPos , 14 , 0
	mov		ah , 0ah
	lea		dx , [max]
	int		21h
	movzx	si , [max + 1]
	mov		[inputBuf + si + 1] , 0	
	call	StringToInt , offset inputBuf + 1
	mov		bx , 100
	sub		bx , ax
	mov		[@@speed] , bl
	mov		ax , 1015h
	mov		[@@cords] , ax
	
	
	
	

	call    ReadScreen  , offset levelName , offset buf
	render
	call	outputString , 0,  0 , offset Info , 4
	xor		ax ,ax
	mov		ah , 1
	mov		[@@pos] , ax
	mov		ah , 1
	mov		[@@color] , ah
	mov		ah , WALL
	mov		[@@wall_char] , ah
	mov		ax , [@@cords]
	movzx	bx , al
	movzx	cx , ah
	call	outputChar , bx , cx , 249 , 3
	mov cx,1fh 
	mov ah,01h
	int 10h
	call	SetCursorPos , 0 , 1
	
@@for:
	call	ReadInputChar
	cmp		ah , KEY_UP
	je		@@up
	cmp		ah , KEY_DOWN
	je		@@down
	cmp		ah , KEY_LEFT
	je		@@left
	cmp		ah , KEY_RIGHT
	je		@@right
	cmp		ah , KEY_ESC
	je		@@exit
	cmp		ah , KEY_F2
	je		@@wall
	cmp		ah , KEY_F4
	je		@@save
	cmp		ah , KEY_F3
	je		@@change_color
	cmp		ah , KEY_CLEAR
	je		@@delete
	cmp		ah , KEY_F6
	je		@@add_wall_char
	cmp		ah , KEY_F5
	je		@@sub_wall_char
	cmp		ah , KEY_F7
	je		@@clear_screen
	cmp		ah , KEY_F8
	je		@@set_start_cords
	jmp		@@for
	
	@@set_start_cords:
	mov		ax , [@@cords]
	movzx	bx , al
	movzx	cx , ah
	call	outputChar , bx , cx , 20h , 7
	mov		ax , [@@pos]
	mov		[@@cords] , ax
	movzx	bx , al
	movzx	cx , ah
	call	outputChar , bx , cx , 249 , 3
	jmp		@@for
	
	@@clear_screen:
	mov		cx , 1000
	xor		si , si
	@@some_loop_1:
	mov		[buf + si] , 20h
	mov		[buf + si + 1] , 7
	add		si , 2 
	loop	@@some_loop_1
	render
	call	outputString , 0,  0 , offset Info , 4
	mov		ax , [@@cords]
	movzx	bx , al
	movzx	cx , ah
	call	outputChar , bx , cx , 249 , 3
	mov		ax , [@@pos]
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx ,cx 
	jmp		@@for
	
	@@sub_wall_char:
	mov		ah , [@@wall_char]
	dec		ah
	mov		[@@wall_char] , ah
	jmp		@@for
	
	@@add_wall_char:
	mov		ah , [@@wall_char]
	inc		ah
	mov		[@@wall_char] , ah
	jmp		@@for
	
	@@delete:
	mov		ax , [@@pos]
	movzx	bx , al
	movzx	cx , ah
	call	outputChar , bx , cx , 20h , 7
	mov		ax , [@@pos]
	movzx	bx , al
	movzx	cx , ah
	inc		cx
	inc		bx
	call	get_pos , bx , cx
	mov		[buf + si] , 20h
	mov		[buf + si + 1] , 7
	jmp		@@for
	
	@@change_color:
	movzx	ax ,  [@@color]
	inc		ax
	cmp		ax , 7
	ja		@@d
	mov		[@@color] , al
	jmp		@@for
	@@d:
	mov		ah , 1
	mov		[@@color] , ah
	jmp		@@for

	@@wall:	
	mov		ax , [@@pos]
	movzx	bx , al
	movzx	cx , ah
	movzx	ax , [@@color]
	movzx	di , [@@wall_char]
	call	outputChar , bx , cx , di , ax
	mov		ax , [@@pos]
	movzx	bx , al
	movzx	cx , ah
	inc		bx
	inc		cx
	call	get_pos , bx , cx
	mov		dl , [@@wall_char]
	mov		[buf + si] , dl	
	mov		ah , [@@color]
	mov		[buf + si + 1] , ah
	jmp		@@for
	
	@@save:

	mov		ah , 3dh
	mov		dx , offset levelName
	mov		al , 1
	int		21h
	jc		@@exit
	mov		si , ax
	push	si
	mov		bx , ax
	mov		ah , 40h
	mov		dx , offset buf
	mov		cx , 2000
	int		21h
	jc		@@exit
	mov		ah , 3eh
	pop		bx   
	int		21h
	mov		ax , [@@cords]
	mov		[inputBuf] , ah
	mov		[inputBuf + 1] , al
	mov		ah , [@@speed]
	mov		[inputBuf + 2] , ah
	mov		ah , 3dh
	mov		dx , offset levelInc
	mov		al , 1
	int		21h
	jc		@@exit
	mov		si , ax
	push	si
	mov		bx , ax
	mov		ah , 40h
	mov		dx , offset inputBuf
	mov		cx , 3
	int		21h
	jc		@@exit
	mov		ah , 3eh
	pop		bx   
	int		21h
	jmp		@@exit
	
	@@up:
	mov		ax , [@@pos]
	dec		ah
	cmp		ah , 0
	je		@@up_2
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	@@up_2:
	mov		ah , screenHeight
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	
	
	@@down:
	mov		ax , [@@pos]
	inc		ah
	cmp		ah , screenHeight
	je		@@down_2
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	@@down_2:
	mov		ah , 1
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	
	
	@@left:
	mov		ax , [@@pos]
	dec		al
	cmp		al , 0
	je		@@left_2
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	@@left_2:
	mov		al , screenWidth
	mov		[@@pos] , ax 
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	
	@@right:
	mov		ax , [@@pos]
	inc		al
	cmp		al , screenWidth
	je		@@right_2
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	@@right_2:
	mov		al , 0
	mov		[@@pos] , ax
	movzx	bx , al
	movzx	cx , ah
	call	SetCursorPos , bx , cx
	jmp		@@for
	
	
	
@@exit:
	call	HideCursor
	ret	   
endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	mov	ax , @data
	mov	ds , ax
	call	initVideo
	call	InitializeRandomGenerator
	call	HideCursor
@@again:
	call    ReadScreen  , offset fileName , offset buf
	call	OutputScreenImage , offset buf
	call	GameMenu , 4 , offset paramString , 8
	cmp	ax , 1
	je	@@start
	cmp	ax , 4
	je	@@exit
	cmp	ax , 2
	je	@@selectLevel
	cmp	ax , 3
	je	@@edit
	jmp	@@again
@@edit:
	call	EditLevel
	jmp	@@again
@@selectLevel:
	call	SelectLevel
	jmp	@@again
@@start:
	mov	ah , 3dh
	mov	dx , offset levelInc
	mov	al , 0
	int	21h
	jc	@@exit
	mov	si , ax
	mov	bx , ax
	mov	ah , 3fh
	mov	dx , offset help
	mov	cx , 3
	int	21h
	jc	@@exit
	mov	ah , 3eh
	mov	bx , si   
	int	21h
	movzx	ax , [help]
	movzx	bx , [help + 1]
	movzx	cx , [help + 2]
	call	StartGame , cx ,offset levelName , bx , ax
	cmp		ax , 1
	je		@@start
	jmp		@@again

@@exit:
	call	ClearScreen
	call	ShutdownVideo
	call	ExitProgram











end	start
