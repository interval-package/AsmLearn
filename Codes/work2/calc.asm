assume cs:code,ds:data,ss:stack
code segment
start:
	mov ax, data	; init regs
	mov ds, ax
	mov ax, stack
	mov ss, ax
	mov sp, 256

	lea ax, input_msg_source
	call printf
	call input_source

	call calc_char

	lea ax, process_msg_doing
	call printf

	call disp_res

	call input_next
	jne start

ending:
	mov ax, 4c00h
	int 21H

calc_char proc far
	lea ax, source_str
	add ax, 2
	mov si, 2

	mov al, source_str+1
	mov cx, ax

	calcing:
	mov dl, source_str[si]
	call core_char_judge
	inc si
	loop calcing

	retf
calc_char endp

core_char_judge proc far
	; input with param in the dl
	core_judging:
		mov al, low_bound_digit
		cmp dl, al
		jb is_others

		mov al, up_bound_digit
		cmp dl, al
		jna is_digit

		mov al, low_bound_letter_upper
		cmp dl, al
		jb is_others

		mov al, up_bound_letter_upper
		cmp dl, al
		jna is_upper_letter

		mov al, low_bound_letter_lower
		cmp dl, al
		jb is_others

		mov al, up_bound_letter_lower
		cmp dl, al
		jna is_lower_letter

		jmp is_others

	judge_end:
		mov ax, [di]
		inc ax
		mov [di], ax
		retf

	is_digit:
		lea di, num_digit
		jmp judge_end

	is_upper_letter:
		lea di, num_letter_upper
		jmp judge_end

	is_lower_letter:
		lea di, num_letter_lower
		jmp judge_end


	is_others:
		lea di, num_other
		jmp judge_end

core_char_judge endp

input_source proc far

	LEA DX, source_str
	MOV AH, 0AH
	INT 21H
	mov al, source_str + 1

	LEA DX, CRLF
	MOV AH, 09H
	INT 21H
	retf
input_source endp

input_next proc far
	; judge the input of the char, and decide next action

	lea ax, input_msg_next
	call printf

	mov ah, 08h
	int 21H

	cmp al, 'q'
	retf
input_next endp

printf proc far
	push dx
	mov dx, ax 
	mov ax, 0900h
	int 21H

	LEA DX,offset CRLF
	MOV AH, 09H					 
	INT 21H

	pop dx
	retf
printf endp

disp_res proc far
	lea dx, disp_num_letter_lower
	mov ah, 09h
	int 21H

	mov dx, num_letter_lower
	call disp_num

	lea dx, disp_num_letter_upper
	mov ah, 09h
	int 21H

	mov dx, num_letter_upper
	call disp_num

	lea dx, disp_num_digit
	mov ah, 09h
	int 21H

	mov dx, num_digit
	call disp_num

	lea dx, disp_num_other
	mov ah, 09h
	int 21H

	mov dx, num_other
	call disp_num

	retf
disp_res endp

disp_num proc far
	push cx

	; this proc attemp to disp a sepecific num
	mov si, 0h
	mov ax, dx
	num_div:
		mov ah, 0h

		div ten
		push ax
		inc si

		cmp al, 0h
		jne num_div

	mov cx, si
	_disp_1:
		pop dx
		mov dl, dh
		add dl, '0'
		mov ah, 02h
		int 21H
		loop _disp_1

	LEA DX, CRLF
	MOV AH, 09H
	INT 21H

	pop cx
	retf
disp_num endp

code ends

data segment
	input_msg_source db "Input the string to be calced: ", '$'
	input_msg_next db "Input q to quit", '$'

	process_msg_doing db "Process the info...", '$'

	disp_num_letter_upper db "Num of upper case letter: ", '$'
	disp_num_letter_lower db "Num of lower case letter: ", '$'
	disp_num_digit db "Num of digit: ", '$'
	disp_num_other db "Num of other: ", '$'

	source_str db 128
	db ?
	db 128 DUP(0), '$'

	num_letter_lower dw 0h
	num_letter_upper dw 0h
	num_digit dw 0h
	num_other dw 0h

	ten db 10

	; for the bounds, we assume at edge
	low_bound_digit db 30h 
	up_bound_digit db 39h
	low_bound_letter_upper db 41h
	up_bound_letter_upper db 5ah
	low_bound_letter_lower db 61h
	up_bound_letter_lower db 7ah


	CRLF DB 0AH, 0DH,'$' 

data ends

stack segment
	dw 256 dup(0)
stack ends

end start