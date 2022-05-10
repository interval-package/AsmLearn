; 
assume cs:code,ds:data,ss:stack

code segment
start:
	mov ax, data	; init regs
	mov ds, ax
	mov ax, stack
	mov ss, ax
	mov sp, 128

	mov ax, offset input_msg_1
	call printf

	call inputf

	mov ax, offset str_res - 3
	call printf

	mov ax, offset buffer
	call printf

	mov ax, offset input_msg_2
	call printf

	mov ax, 4c00h
	int 21H

data segment
input_msg_1 db "Input the String:", '$'
input_msg_2 db "Here is the end.", '$'

; we assume use this to store the str body

; first store the length of buffer
buffer db 20
; here we store the len of the gotten str
db ?
str_res db "123456789012345678901234567890", '$'

CRLF DB 0AH, 0DH,'$' 

data ends

stack segment
dw 256 dup(0)
stack ends

; proc will use the ax to get the msg

printf proc far
	mov dx, ax 
	mov ax, 0900h
	int 21H

	; 換行
	LEA DX,offset CRLF             
	MOV AH, 09H					 
	INT 21H

	retf
printf endp

inputf proc far
	push es

	; get the str
	LEA DX, buffer
	mov ah, 0ah
	int 21H

	; process the str
	; get the len of tar str
	mov bx, dx
	mov ax, [bx + 1]
	; get the pos of end sym
	add al, 2
    mov ah, 0
    ; store to reg
    mov di, ax

    ; get the obsolute pos of str end
    mov ax, offset buffer
    mov es, ax
    ; w the end sym
    mov dx, '$'
    MOV es:[di], dx

    ; 換行
	LEA DX,offset CRLF             
	MOV AH, 09H					 
	INT 21H

	pop es
	retf
inputf endp

code ends

end start
