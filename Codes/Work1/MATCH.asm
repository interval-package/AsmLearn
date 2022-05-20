; in this function we implement the str match function
; we have two types of match
; the 'times' we'd calc the times of a str apears
; the pos get the pos of the str first occurs

assume cs:code,ds:data,ss:stack

code segment
	start:
		mov ax, data	; init regs
		mov ds, ax
		mov ax, stack
		mov ss, ax
		mov sp, 128

	work:
		lea ax, input_msg_phrase
		call printf

		call input_source
		
		lea ax, input_msg_tar
		call printf

		call input_tar

		call certify_input

		mov al, _find
		cmp al, 1h
		jne next_time

		lea ax, process_msg_doing
		call printf

		call process_data_pos

		call end_judge

	next_time:

		call input_next
		je work

	ending:
		mov ax, 4c00h
		int 21H

; proc will use the ax to get the msg
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

input_tar proc far
	LEA DX, destin_str
	MOV AH, 0AH
	INT 21H
	mov al, destin_str + 1

	LEA DX, CRLF
	MOV AH, 09H
	INT 21H
	retf
input_tar endp

input_next proc far
	;	judge the input of the char, and decide next action

	lea ax, input_msg_next
	call printf

	mov ah, 08h
	int 21H

	cmp al, 'C'
	retf
input_next endp

process_data_times proc far
	; load the data
	mov _find, 0h

	mov al, source_str+1
	mov ah, 0h
	mov cx, ax
	
	mov si, 2
	mov dx, 0

	cmping:
		push cx
		push si
		mov al, destin_str+1
		mov ah, 0h
		mov cx, ax
		mov di, 2
		
		subcmp:
			mov ah, source_str[si]
			mov al, destin_str[di]
			cmp ah, al
			jne subcmp_fail
			inc di
			inc si
		loop subcmp

		jmp subcmp_success

		subcmp_next:
			; 将si复位
			pop si
			inc si
			pop cx
	
	loop cmping
	
	audition:
		cmp dx, 0
		ja audition_success
	res:
	retf
	
	subcmp_success:
		inc dx
		jmp subcmp_next

	subcmp_fail:
		jmp subcmp_next

	audition_success:
		mov _find, 1h
		jmp res

	audition_fail:
		jmp res
process_data_times endp

process_data_pos proc far
	mov _find, 0h

	mov al, source_str+1
	mov ah, 0h
	mov cx, ax
	mov si, 2
	; using the ah to store flag of success
	mov dh, 01h

	pos_get_main:
		push cx
		push si
		mov al, destin_str+1
		mov ah, 0h
		mov cx, ax
		mov di, 2

		pos_get_sub:

			mov ah, source_str[si]
			mov al, destin_str[di]
			cmp ah, al
			jne pos_get_fail
			inc di
			inc si
		loop pos_get_sub
		
		jmp pos_get_success

		pos_get_next:
			pop si
			inc si
			pop cx
	loop pos_get_main

	pos_get_res:
		retf

	pos_get_success:
		; after this func we should clean the stack
		pop ax
		pop ax

		mov dx, si
		sub dx, 2
		mov _find, 1h
		jmp pos_get_res

	pos_get_fail:
		jmp pos_get_next
process_data_pos endp

certify_input proc far
	mov _find, 0h

	mov dl, destin_str+1
	cmp dl, 0
	je certify_empty
	mov al, source_str+1
	cmp dl, al
	jnb certify_overflow

	lea ax, certification_valid
	call printf
	mov _find, 1h

	certify_end:
		retf

	certify_empty:
		lea ax, certification_empty
		jmp certify_end

	certify_overflow:
		lea ax, certification_overflow
		call printf
		jmp certify_end
certify_input endp

end_judge proc far
	push dx
	mov al, _find
	cmp al, 0h
	ja judge_success

	judge_fail:
		pop dx
		lea ax, disp_audition_fail
		call printf
		jmp judge_res

	judge_success:
		lea dx, disp_audition_success
		mov ah, 09h
		int 21H

		pop dx
		call disp_num
		jmp judge_res

	judge_res:
		retf
end_judge endp

disp_num proc far
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
	_disp:
		pop dx
		mov dl, dh
		add dl, '0'
		mov ah, 02h
		int 21H
		loop _disp
	LEA DX, CRLF
	MOV AH, 09H
	INT 21H

	retf
disp_num endp

code ends

data segment

	input_msg_phrase db "Input the String of phrase:", '$'

	input_msg_tar db "Input the String of your target", '$'

	input_msg_next db "Press C(Upper case) to continue this func", '$'

	process_msg_doing db "Process the info...", '$'

	disp_audition_success db "Audition finish, calc result: ", '$'

	disp_audition_fail db "Audition finish, no match.", '$'

	certification_empty db "Get empty input, please check.", '$'

	certification_overflow db "Get destinated string longger than source.", '$'

	certification_valid db "Get valid inputs.", '$'

	source_str db 200
		db ?
		db 200 DUP(0), '$'

	destin_str db 20
		db ?
		db 20 DUP(0), '$'

	CRLF DB 0AH, 0DH,'$' 

	_find db 0

	ten db 10
data ends

stack segment
	dw 256 dup(0)
stack ends

end start
