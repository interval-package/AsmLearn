assume cs:code
code segment
main:
	mov ax,cs
	mov ds,ax
	mov si,offset rupt0;设置传送的起点

	mov ax,0
	mov es,ax
	mov di,200h;设置传送的终点
	
	mov cx,offset rupt0end - offset rupt0
	cld
	rep movsb;完成传送中断程序
	
	mov ax,0
	mov es,ax
	mov word ptr es:[0],200h
	mov word ptr es:[2],0;修改向量表
	
	mov ax,1000h
	mov bh,1
	div bh;实验除法溢出
	
	mov ax,4c00h
	int 21h
	
	rupt0:
		jmp short go
		flow_msg: db 'overflow!'
	
		go:
			mov ax,cs
			mov ds,ax
			mov si,0202h;设置源数据
	
			mov ax,0b800h
			mov es,ax
			mov di,160*12+32*2;设置显存中显示位置
	
			mov cx,9
			lp:
				mov al,ds:[si]
				mov es:[di],al
				inc si
				add di,2
			loop lp
			
			mov ax,4c00h
			int 21h
	rupt0end:nop
code ends
end main
