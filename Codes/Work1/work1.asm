; 
assume cs:code,ds:data,ss:stack

code segment
start:
	mov ax, data	; init regs
	mov ds, ax
	mov ax, stack
	mov ss, ax
	mov sp, 128

	lea ax, input_msg_1
	call printf

	call inputf

	lea ax, input_msg_2
	call printf

	call outputf

	mov ax, 4c00h
	int 21H

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

	LEA DX, BUFFER
	MOV AH, 0AH
	INT 21H
	mov al, buffer + 1
	; MOV AL, ds:[BUFFER+1]
	; the two above are eq
	ADD AL, 2
	MOV AH, 0
	MOV SI, AX
    MOV BUFFER[SI], '$'

; 	CRLF
	LEA DX,offset CRLF             
	MOV AH, 09H					 
	INT 21H

	retf
inputf endp

outputf proc far
; display the inputed str
	LEA DX, BUFFER+2
	MOV AH, 09H							 
	INT 21H

	LEA DX,offset CRLF             
	MOV AH, 09H					 
	INT 21H

	retf
outputf endp

code ends

data segment
input_msg_1 db "Input the String:", '$'
input_msg_2 db "Now we get the str:", '$'

; we assume use this to store the str body

; first store the length of buffer
buffer db 20
; here we store the len of the gotten str
db ?
db 20 DUP(0), '$'

CRLF DB 0AH, 0DH,'$' 

data ends

stack segment
dw 256 dup(0)
stack ends

end start
