
assume cs:code,ds:data,ss:stack,es:extra

data segment
input_msg_1 db "Input the String:", 0AH, 0DH, '$'
data ends

stack segment
dw 256 dup(0)
stack ends

extra segment
dw 256 dup(0)
extra ends

code segment

start:
	mov ax, data	; init regs
	mov ds, ax
	mov ax, stack
	mov ss, ax
	mov ax, extra
	mov es, ax

	mov esi, offset input_msg_1
	call print

	mov ax, 0100h
	int 21H

print proc near uses esi
	mov ax, esi
	mov dx, ax
	mov ax, 0900h
	int 21H
	ret
endp

code ends

end start