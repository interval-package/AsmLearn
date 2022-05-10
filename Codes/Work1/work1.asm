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

	mov ax, offset input_msg_2
	call printf

	call outputf

	mov ax, 4c00h
	int 21H

data segment
input_msg_1 db "Input the String:", '$'
input_msg_2 db "Now we get the str:", '$'

; we assume use this to store the str body

; first store the length of buffer
buffer db 20
; here we store the len of the gotten str
db ?
db "123456789012345678901234567890", '$'

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

	LEA DX, BUFFER                        ;接收字符串
	MOV AH, 0AH
	INT 21H
	MOV AL, BUFFER+1                     ;对字符串进行处理
	ADD AL, 2
	MOV AH, 0
	MOV SI, AX
    MOV BUFFER[SI], '$'

    ; 換行
	LEA DX,offset CRLF             
	MOV AH, 09H					 
	INT 21H

	retf
inputf endp

outputf proc far

	LEA DX, BUFFER+2                     ;输出输入的字符串
	MOV AH, 09H							 
	INT 21H

	LEA DX,offset CRLF             
	MOV AH, 09H					 
	INT 21H

	retf
outputf endp

code ends

end start
