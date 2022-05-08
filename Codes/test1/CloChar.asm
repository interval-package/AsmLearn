assume cs:code,ds:data,ss:stack
data segment
 db 'welcome to masm!'
data ends

stack segment
 db 10 dup (0)
 dw 02H,24H,71H 	;字符的属性：02H为黑底绿字，24H为绿底红字，71H为白底蓝字
stack ends

code segment
start: mov ax,data
	mov ds,ax

	mov ax,stack
 	mov ss,ax
	mov sp,10 	;将栈顶指向堆栈中存放的字符属性

	mov ax,0b800H
 	mov es,ax  	;将显示缓冲区的段地址送入ES
 	mov bp,6e0H 	;BP用来定位显示的行，初始为第11行（从0行记起）

	;AL作为中间变量存放字符的属性，注意栈操作只能为字型数据

	mov cx,3
s0: mov dx,cx 	
	;DX暂存外循环变量的值
 	mov bx,0  	;BX用来定位内存的偏移地址
 	mov si,40H 	;SI用来定位显示的列，初始为第64列（从0列记起）
 	pop ax  	;从堆栈中取得字符属性，AL部分有效，但是还是取整个ax

	mov cx,16
	s: 
	mov ah,ds:[bx]
 	mov es:[bp][si],ah 	
 	; 存放字符的ASCII码
 	mov es:[bp][si].1,al  	
 	; 存放字符的属性
 	inc bx
 	add si,2
	loop s

	add bp,0a0H
	; 换行
 	mov cx,dx 	
 	;DX恢复外循环变量的值
 	loop s0

	mov ax,4c00H
 	int 21H
code ends
end start
