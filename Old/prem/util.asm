.486
ideal
include "header.inc"
include "util.inc"

segment _TEXTSEG public
assume cs:_TEXTSEG, ds:NOTHING, ss:NOTHING



proc parse_command_line
ARG @@argv_buffer:word, @@line_len: word, @@line_seg:word, @@command_line:word
; Returns ax = argc
	push	es
	push	bx
	push	si
	push	di

	mov 	ax, [@@line_seg]
	mov	es, ax
        mov	si, [word ptr @@command_line]
	mov	bx, [@@argv_buffer]
	xor	di, di
	mov	cx, [@@line_len]
	
	jcxz	@@1

@@7:
; Search for word begin
@@3:
	mov	al, [es:si]
	cmp	al, ' '
	ja	@@2
	
	inc	si
	dec	cx
	jz	@@1
	jmp	@@3
	
@@2:	
	cmp	al, '"'
	jz	@@4

; Store word pointer
	mov	[bx + di], si
	add	di, pointer

; Look for end of the word
@@6:
	mov	al, [es:si]
	cmp	al, ' '
	jbe	@@5
	
	inc	si
	dec	cx
	jnz	@@6

; if string ended, store 0 and exit
	mov	[byte ptr es:si], 0
	jmp	@@1

; if word is in quotes "aaa bbb"
@@4:
; look for another '"'
	inc	si
	dec	cx
	jz	@@1

	mov	[bx + di], si
	add	di, pointer

@@9:
	mov	al, [es:si]
	cmp	al, '"'
	jz	@@8
	
	inc	si
	dec	cx
	jnz	@@9

; if string ended, store 0 and exit
	mov	[byte ptr es:si], 0
	jmp	@@1

@@8:
@@5:
	mov	[byte ptr es:si], 0
	inc	si
	dec	cx
	jnz	@@7	
	
@@1:
	mov	ax, di
	shr	ax, pointer_bits

	pop	di
	pop	si	
	pop	bx
	pop	es
	ret
endp



proc convert_atou
ARG @@number_string:word  ; 0..65535
; returns ax = unsigned integer result
	push	si

	xor	cx, cx
	xor 	ah, ah
	mov	si, [@@number_string]

@@2:
	movzx	ax, [byte ptr si]	
	cmp 	al, '9'
	ja	@@1
	sub	al, '0'
	jb	@@1
	xchg	ax, cx
	mov 	dx, 10
	mul	dx
	add 	cx, ax
	inc	si
	jmp	@@2
	
	
@@1:
	mov	ax, cx

	pop	si
   	ret
endp


proc convert_atoi
ARG @@number_string:word 
; returns ax = signed integer result
	push	si

	mov	si, [@@number_string]
	mov 	al, [si]
	
	cmp	al, '-'
	pushf
	jz	@@2
	cmp	al, '+'
	jnz	@@3

@@2:
	inc	si

@@3:
	call	convert_atou, si	

	popf
	jnz	@@1
	neg	ax

@@1:
	pop	si
   	ret
endp

proc	intToString
ARG	@@number:word , @@mass:word
	mov	ax , [@@number]
	mov	di , 0
	mov	si , 10
	mov     bx , [@@mass]
@@first_step:

	xor	dx , dx
	div	si
	add	dx , 30h
	mov	[byte ptr bx + di], dl
	inc	di
	cmp	ax , 1
	jc	@@next_step
	jmp	@@first_step

@@next_step:

	cmp	di , 1
        jz	@@oneParam
	push	di
	mov	si , 0
	mov	cx , di
	and	cx , 11111110b
	shr	cx , 1	
	dec	di
	

	

@@for:
	mov	al , [byte ptr bx + si]
	mov	ah , [byte ptr bx + di]		
	mov	[byte ptr bx + si] , ah
	mov	[byte ptr bx + di] , al
	dec	di
	inc	si
	loop	@@for
	

@@moreParam:


	pop     di	
	mov	[byte ptr bx + di] , '$'
	jmp	@@exit


 @@oneParam:
	
	mov	[byte ptr bx + 1] , '$'


 @@exit:

		ret
	
endp

proc	PartialRemainder
Arg	@@Base: word, @@Exponent: word, @@Modulo: word

	mov	ax, [@@Exponent]
	cmp	ax, 1
	jb	@@exponent_0
	je	@@exponent_1

	shr	ax, 1
	jc	@@odd_number

	call	PartialRemainder, [@@Base], ax, [@@Modulo]
	
	mul	ax
	jmp	@@div_and_exit

@@odd_number:
	push	ax; sub sp, 2
		  ; mov	[sp], ax

	call	PartialRemainder, [@@Base], ax, [@@Modulo]
	pop	dx ; get previous argument
	push	ax ; push result
	
	inc	dx ; increment argument
	call	PartialRemainder, [@@Base], dx, [@@Modulo]
	pop	dx ; pop first result
		   ; mov  dx, [sp]
		   ; add  sp, 2

	mul	dx
	jmp	@@div_and_exit

@@exponent_1:
	mov	ax, [@@Base]
	xor	dx, dx

@@div_and_exit:
	div	[@@Modulo]
	mov	ax, dx
	jmp	@@exit

@@exponent_0:
	mov	ax, 1 ; a^0 mod b == 1 for any b

@@exit:
	ret
endp

ends

end
 