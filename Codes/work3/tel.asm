assume cs:code,ds:data,ss:stack
code segment
start:
	mov ax, data	; init regs
	mov ds, ax
	mov ax, stack
	mov ss, ax
	mov sp, 1024

to_next_phase:
	call next_phase
	cmp al, 'q'
	je end_phase
	cmp al, 's'
	je search_phase
	jmp start

end_phase:
	mov ax, 4c00h
	int 21H

search_phase:
	jmp to_next_phase

input_add_item proc far
	lea ax, msg_add_item
	call printf

	lea ax, msg_input_name
	call printf

	lea ax, name_buffer

	lea ax, msg_input_tel
	call printf

	retf
input_add_item endp

core_search proc far
	retf
core_search endp

input_search proc far
	retf
input_search endp

next_phase proc far
	; judge the input of the char, and decide next action

	lea ax, msg_next_phase
	call printf

	mov ah, 08h
	int 21H
	retf
next_phase endp

inputf proc far
	mov dx, ax
	mov ah, 0ah
	int 21H
inputf endp

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

code ends

data segment
	msg_add_item db "Now is to register your tel.", '&'
	msg_input_name db "Input name:", '$'
	msg_input_tel db "Input tel number:", '$'
	msg_search_phase db "here is the search_phaseing mode"
	msg_next_phase db "Input q to quit, s to search_phase info, others to continue", '$'

	name_buffer db 25
	db ?
	db 25 DUP(0), '$'

	tel_buffer db 16
	db ?
	db 16 dup(0), '$'

	; num of current name tab
	name_num db 0
	; pos 1 stores the length of name
	; pos 2 stores the index of tel in tab
	; so the len of each item is 25
	name_tab db 50 dup(?,?,"12345678901234567890$$$")

	; num of current tel tab
	tel_num db 0
	; the length of tel is fixed 8, so the length of each item is 10
	; pos 1 stores the index of name in tab
	tel_tab db 50 dup(?,"12345678",'$')

	CRLF DB 0AH, 0DH,'$' 

data ends

stack segment
	dw 1024 dup(0)
stack ends

end start