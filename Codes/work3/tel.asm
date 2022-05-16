;
; I acknowledge that I do not really think a lot about effectiveness
; that the algorithm may not be best 
;

assume cs:code,ds:data,ss:stack

stack segment
	dw 1024 dup(0)
stack ends

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
		jmp add_phase

	end_phase:
		mov ax, 4c00h
		int 21H

	search_phase:
		call input_search
		jmp to_next_phase

	add_phase:
		call input_add_item
		jmp to_next_phase

core_sort_input proc far
	; this func will sort and save info

	mov al, tel_num
	sub al, 1
	mov temp_id_ptr, al

	; get the current num of array
	mov al, name_num
	mov ah, 0
	cmp al, ah
	je sort_empty
	mov cx, ax
	mov dx, 0

	sort_main:
		mov ax, dx
		call compare_name
		jna sort_is_low
		jmp sort_loop_end

		sort_loop_end:
			inc dx
	loop sort_main

	; fill the end of table
	mov ax, dx
	call swap_name

	sort_finish:
		; end phase update info
		mov al, name_num
		inc al
		mov name_num, al

		retf

	sort_empty:
		call swap_name
		jmp sort_finish

	sort_is_low:
		mov ax, dx
		call swap_name
		jmp sort_loop_end
core_sort_input endp

input_add_item proc far
	lea ax, msg_add_item
	call printf

	lea ax, msg_input_name
	call printf

	mov ax, offset name_buffer
	call inputf

	lea ax, msg_input_tel
	call printf

	lea ax, tel_buffer
	call inputf

	; here will do the validity judge, and save the tel from buffer
	call save_tel
	jne add_fail

	; and then we try to store the name with sort method
	call core_sort_input

	lea ax, msg_input_success
	call printf

	retf

	add_fail:
		lea ax, msg_input_fail
		call printf
		retf
input_add_item endp

core_search proc far
	mov al, name_num
	mov ah, 0
	mov cx, ax

	mov ax, 0

	search_name:
		call disp_num
		call compare_name
		je name_find 
		inc ax
	loop search_name

	lea ax, msg_not_find
	call printf

	search_finish:
	retf

	name_find:
		mov dx, ax
		lea ax, msg_find
		call printf

		mov al, dl
		call locate_name_id
		mov ax, di
		add ax, 2
		call printf

		mov al, [di+1]
		call locate_tel_id
		mov ax, di
		add ax, 2
		call printf

		jmp search_finish
core_search endp

input_search proc far
	; call disp_total_info

	lea ax, msg_search_input
	call printf

	lea ax, msg_input_name
	call printf

	lea ax, name_buffer
	call inputf

	call core_search

	retf
input_search endp

compare_name proc far
	; input with index in name table, in al
	; this func would use si, di for comparing
	; this func only returns with flag of cmp and should not change too much out env
	push si
	push di
	push bx
	push cx
	push ax

	; transfer the al to di
	call locate_name_id

	lea si, name_buffer

	; init cx
	mov al, name_buffer+1
	mov ah, 0
	mov cx, ax

	mov bx, 2
	; when comparing using ah buf, al tab
	comp_single:
		mov ah, [bx+si]
		mov al, [bx+di]
		cmp ah, al
		jne comp_end
		inc bx
		loop comp_single

	mov ah, name_buffer+1
	mov al, [di]
	cmp ah, al
	jne comp_end

	comp_end:
		pop ax
		pop cx
		pop bx
		pop di
		pop si
		retf
compare_name endp

swap_name proc far
	push cx
	push dx
	; we assume that we get al of the tar num
	; and this func would swap the num to the buffer

	; get tar pos, in the di
	call locate_name_id

	; swap the len
	mov ah, [di]
	mov al, name_buffer+1
	mov [di], al
	mov name_buffer+1, ah
	

	; cache the temp_ptr
	mov dl, [di+1]
	mov al, temp_id_ptr
	mov temp_id_ptr, dl
	mov [di+1], al

	; swapping the body

	mov ax, 2
	mov si, ax

	; swap all, including the useless data
	mov ax, 20
	mov cx, ax

	add di, 2
	swap_main:
		mov dl, name_buffer[si]
		mov al, [di]
		mov name_buffer[si], al
		mov [di], dl
		inc si
		inc di
		loop swap_main

	pop dx
	pop cx
	retf
swap_name endp

save_tel proc far
	push bx

	tel_valid_judge:
		mov al, tel_buffer+1
		cmp al, eight
		jne tel_end

	; here take caution, add action will change the flag
	mov al, tel_num
	call locate_tel_id
	add di, 1
	mov ax, 2
	mov si, ax
	mov cx, 8

	tel_save:
		mov al, tel_buffer[si]
		mov [di], al
		inc di
		inc si
		loop tel_save

	mov ah, tel_num
	inc ah
	mov tel_num, ah

	mov ax, 0
	cmp ah, al

	tel_end:
		pop bx
		retf
save_tel endp

locate_tel_id proc far
	push dx
	; to locate pos, assume num store in al
	mov ah, 10
	mul ah
	lea dx, tel_tab
	add ax, dx
	mov di, ax
	; return in di
	pop dx
	retf
locate_tel_id endp

locate_name_id proc far
	push dx
	; to locate pos, assume num store in al
	mov ah, 25
	mul ah
	lea dx, name_tab
	add ax, dx
	mov di, ax
	; return in di
	pop dx
	retf
locate_name_id endp

disp_total_info proc far
	push ax
	push cx
	push dx

	mov al, tel_num
	mov ah, 0
	mov cx, ax

	mov ax, 0

	cmp ax, cx
	je disp_total_end

	mov dx, 0

	disp_total_loop:
		mov al, dl
		call locate_name_id
		mov ax, [di]
		call disp_num
		mov ax, [di+1]
		call disp_num
		mov ax, di
		add ax, 2
		call printf

		mov al, dl
		call locate_tel_id
		mov ax, di
		inc ax
		call printf

		inc dl
	loop disp_total_loop

	disp_total_end:
		pop dx
		pop cx
		pop ax
		retf
disp_total_info endp

next_phase proc far
	; judge the input of the char, and decide next action

	lea ax, msg_next_phase
	call printf

	mov ah, 08h
	int 21H
	retf
next_phase endp

inputf proc far
	push dx
	push bx
	mov dx, ax
	mov ah, 0AH
	int 21H

	mov bx, dx
	mov al, [bx+1]
    ADD AL,2
    MOV AH, 0
    add bx, AX
    mov al, '$'
    MOV [bx], al

	lea dx, CRLF
	mov ah, 09h
	int 21H
	pop bx
	pop dx
	retf
inputf endp

printf proc far
	push dx
	push ax
	mov dx, ax 
	mov ax, 0900h
	int 21H

	LEA DX,offset CRLF
	MOV AH, 09H
	INT 21H

	pop ax
	pop dx
	retf
printf endp

disp_num proc far
	push cx
	push si
	push dx
	push ax

	; input with al
	; this proc attempt to disp a specific num
	mov si, 0h
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

	pop ax
	pop dx
	pop si
	pop cx
	retf
disp_num endp

code ends

data segment
	msg_add_item db "Now is to register your tel.", '$'
	msg_search_input db "Now is search phase.", '$'

	msg_input_name db "Input name:", '$'
	msg_input_tel db "Input tel number:", '$'
	msg_input_fail db "Error input!", '$'
	msg_input_success db "Success input", '$'
	
	msg_find db "Find info.", '$'
	msg_not_find db "Sorry not find.", '$'
	msg_next_phase db "Input q to quit, s to search_phase info, others to continue.", '$'

	name_buffer db 250
	db ?
	db 250 dup('1'), '$'

	tel_buffer db 16
	db ?
	db 16 dup(0), '$'

	temp_id_ptr db 00h

	; num of current name tab
	name_num db 00h

	; pos 1 stores the length of name
	; pos 2 stores the index of tel in tab
	; so the len of each item is 25

	name_tab db 50 dup(255,0,"1234567890123456789000$")

	; num of current tel tab
	tel_num db 00h
	; the length of tel is fixed 8, so the length of each item is 10
	; pos 1 stores the index of name in tab

	tel_tab db 50 dup(?,"12345678",'$')

	eight db 08h

	ten db 0ah

	CRLF DB 0AH, 0DH,'$' 
data ends

end start