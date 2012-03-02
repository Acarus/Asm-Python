.486
ideal
include "header.inc"
include "util.inc"

macro  SWAP_DS_ES
		push	ds
		push	es
		pop	ds
		pop	es
endm




segment _TEXTSEG public


;		es:0000 and ds:0000 - points to PSP
;
		assume	cs:_TEXTSEG, ds:_DATASEG, es:NOTHING, ss: _STACKSEG


start_program:
		mov	ax, _DATASEG
		mov	ds, ax

		movzx	cx, [es:program_params_len]		
		call	parse_command_line, offset argv, cx, es, program_params_str
		mov	[argc], ax

		cmp	ax, 3
		mov	dx, offset msg_not_enough_params
		jne	@@error_exit

		mov	bx, ax

		SWAP_DS_ES

@@loop_by_params:		
		mov	si, 3
		sub	si, bx
		shl	si, 1
	
		mov	ax, [es:argv + si]
		call	convert_atou, ax
		mov	[es:param_numbers + si], ax

		dec	bx
		jnz	@@loop_by_params

		SWAP_DS_ES
           	
		call PartialRemainder  , [param_numbers] , [param_numbers + 2]  , [param_numbers + 4 ]
		call intToString , ax , offset result
		mov	ah , 09h
		lea	dx , result
		int	21h
		jmp	@@clean_exit


@@error_exit:
		mov	ah, 9				; функц_я виводу на екран
		int	21h				; вив_д на екран
  
	


@@clean_exit:
		mov	ax, 4c00h			; функц_я виходу з програми з кодом повернення 0
		int	21h				; вих_д з програми

ends


segment _DATASEG
helloMsg	db	'Hello in my program . You gave paramets : $'
argc		dw	0
argv		dw	64 dup (0)
result		db 	10 dup (?)

param_numbers	dw	4 dup (0)

msg_not_enough_params:
		db 	'Three parameters required$'

ends


segment		_STACKSEG private uninit stack
		dw	256 dup (?)
ends


end start_program