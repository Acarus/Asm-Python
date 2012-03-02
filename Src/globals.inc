

word_bits	equ	1
dword_bits	equ	2

pointer		equ	word
pointer_bits	equ	word_bits

;; All functions preserve: bx, si, di


model		small, pascal
locals

program_params_len	equ	80h
program_params_str	equ	81h
