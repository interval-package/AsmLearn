assume cs:code,ds:data,ss:stack
code segement
start:
	mov ax, data	; init regs
	mov ds, ax
	mov ax, stack
	mov ss, ax
	mov sp, 256

	lea ax, input_msg_source
	call printf
	call input_source

	lea ax, process_msg_doing
	call printf

	call input_next
	jne start

ending:
	mov ax, 4c00h
	int 21H

core_char_judge proc far
	; input with param in the dx
	retf
code_char_judge endp


disp_res proc far

	retf
disp_res endp


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

disp_num proc far
	push cx

	; this proc attemp to disp a sepecific num
	mov si, 0h
	mov ax, dx
	mov ah, 0h
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

date segement
	input_msg_source db "Input the string to be calced: ", '$'
	input_msg_next db "Input q to quit", '$'

	process_msg_doing db "Process the info...", '$'

	disp_num_letter db "Num of letter: ", '$'
	disp_num_digit db "Num of digit: ", '$'
	disp_num_other db "Num of other: ", '$'

	source_str db 128
	db ?
	db 128 DUP(0), '$'

	num_letter dw 0h
	num_digit dw 0h
	num_other dw 0h

data ends

stack segment
	dw 256 dup(0)
stack ends

end start