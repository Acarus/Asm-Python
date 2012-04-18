

word_bits	equ	1
dword_bits	equ	2

pointer		equ	word
pointer_bits	equ	word_bits



model		tiny, pascal
locals

program_params_len	equ	80h
program_params_str	equ	81h


macro	PUSH_PROC_REGS
	push	bx
	push	si
	push	di
endm

macro	POP_PROC_REGS
	pop	di
	pop	si
	pop	bx
endm



struc ScreenCoord
coordX		db 	?
coordY		db 	?
ends

struc ScreenChar
charCode	db 	?
charAttr	db	?
ends


;; All functions preserve: bx, si, di
