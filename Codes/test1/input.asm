data segment
	mess1 db 'Input x:','$'
	mess2 db 0ah,0dh,'Output y:$' ;0ah和0dh是换行和回车
	y db ?
data ends
 
code segment
assume cs:code,ds:data
start:mov ax,data
	mov ds,ax
	mov dx,offset mess1
	
	mov ah,9   ;显示提示信息"Input x:"
	int 21h
	
	mov ah,1   ;1号功能，键盘输入，键入的值在al
	int 21h
	
	add al,1   ;al+1->al
	mov y,al   ;保存到y单元
	
	mov dx,offset mess2
	mov ah,9   ;在下一行显示提示信息"Output y:"
	int 21h
	
	mov ah,2   ;2号功能，显示一个字符
	mov dl,y   ;显示的字符要放入dl,显示x+1的值
	int 21h
	
	mov ah,4ch
	int 21h
code ends
end start