data segment
   hintinput db "Input string:$"
   hintoutput1 db "Output the number of non-alpha characters:$";
   hintoutput2 db "Non-alphabetical characters flashing:$";
   hintoutput3 db "maxth ch:$";
           buf db 200
	           db ?
	           db 200 dup(?)
         count db 0
crlf db 0ah,0dh,'$'
data ends

stack segment stack
   string db 500 dup(?)
stack ends

extra segment   ;定义附加段

extra ends

codes segment
	assume cs:codes,ds:data,ss:stack,es:extra
	main proc far
start:
  mov ax,data  ;分别将数据段，堆栈段，附加段送入代码段
  mov ds,ax
  mov ax,stack
  mov ss,ax
  mov ax,extra
  mov es,ax

  lea dx,hintinput ;输入提示语
  mov ah,9h;输出功能入口在dx
  int 21h
  lea dx,crlf;输入提示语后，回车换行
  mov ah,09
  int 21h

  mov ah,0ah;输入功能入口在dx
  lea dx,buf
  int 21h

  lea dx,crlf        
  mov ah,9
  int 21h
;------------------------------------首先用cl储存字符串长度，si源变址寄存器指向串真正开始的地方
  mov cl,buf+1;cl中放置实际字符串长度
                               
  lea si,buf+2;si放置字符串首地址
;------------------------------------首先输出提示语回车换行，以十进制输出字符串中非字母字符的个数（不是a to z或 A to Z）。
  
  call print1

  call print2

  call print3

  mov ah,4ch
  int 21h
  main endp
  
print1 proc near                        
  push cx
  push si
  lea dx,hintoutput1 ;输出提示语
  mov ah,09h;输出功能入口在dx
  int 21h
  lea dx,crlf;输入提示语后，回车换行
  mov ah,09
  int 21h
  mov dl,0 ;用dl来计数，统计符串中非字母字符的个数
L0:
  mov al,[si]
  cmp al,'A'      
  jb L1           ;
  cmp al,'Z'      
  jbe L2           ;
  cmp al,'a'      
  jb L1           ;
  cmp al,'z'      
  jbe L2           ;

L1:
  inc dl     ;计数器加1
L2:
  inc si
  dec cl
  jnz L0
;----------------------------------输出非字母字符的个数dl

  cmp dl,9h
  jbe L             ;如果非字母个数小于10，则直接加30输出
  mov dh,0           ;否则把dx存入ax中
  mov ax,dx
  mov bl,10               ;ax除以10后，ah作为商
  div bl                              ;al作为余数
  mov dl,al
  mov ch,al           ;防止ah中的商被02h冲掉，先把商转移到ch中
  add dl,30h            ;先输出商，再输出余数，就是10进制了
  mov ah,02h
  int 21h

  mov dl,ch
L:
  add dl,30h
  mov ah,02h
  int 21h
  lea dx,crlf     ;输出后，回车换行
  mov ah,09
  int 21h
  pop si
  pop cx
  ret
  
print2 proc near
  lea dx,hintoutput2 ;输出提示语
  mov ah,09h         ;输出功能入口在dx
  int 21h
  lea dx,crlf        ;输入提示语后，回车换行
  mov ah,09h
  int 21h
  push cx
  push si
  cld                ;方向标志位df清零
  
L3: 
  push cx 
  lodsb            ;从字符串串中取数据至al
  cmp al,'A'      
  jb L4            ;如果字符<'A',跳转到L4
  cmp al,'Z'      
  jbe L5           ;如果字符<='Z',跳转到L5
  cmp al,'a'      
  jb L4            ;如果字符<'a',跳转到L4
  cmp al,'z'      
  jbe L5           ;如果字符<='Z',跳转到L5
L4:                ;如果不是字母，则进行闪烁输出
   mov bl,10000111b  ;bl属性闪烁输出
   mov bh,0        ;显示页为0
   mov cx,1        ;显示字符为1个
   mov ah,09h
   int 10h         ;输出bl属性的字符串
   mov ah,03h
   int 10h         ;读光标位置
   inc dl          ;输出列+1
   mov ah,02h
   int 10h         ;置光标位置
   jmp L6
L5:
   mov bl,00000111b   ;bl属性为平常输出
   mov bh,0            ;显示页为0
   mov cx,1           ;显示字符个数为1个
   mov ah,09h
   int 10h             ;输出属性为bl的字符
   mov ah,03h
   int 10h             ;读光标位置
   inc dl              ;输出列+1
   mov ah,02h
   int 10h             ;置光标位置
L6:
  pop cx
  loop L3
  
  lea dx,crlf           ;输入提示语后，回车换行
  mov ah,09
  int 21h
  pop si
  pop cx
  ret

print3 proc near
  lea dx,hintoutput3  ;输出提示语
  mov ah,09h          ;输出功能入口在dx
  int 21h
  lea dx,crlf         ;输入提示语后，回车换行
  mov ah,09
  int 21h
  push cx
  push si
            ;count用来存放ascill最大的字符
L7:   
  mov al,[si]
  cmp al,count       ;比较al和count的大小，如果al>count，则令al=count
  jbe L8
  mov count,al        
L8:  
  inc si
  dec cl
  jnz L7
  pop si
  pop cx
  cld
 L9: 
  push cx 
  lodsb               ;从串中取数据至al
  cmp al,count      
  jz L11           ;如果字符==ascill码最大字符
L10:                
   mov bl,00000111b   ;bl属性正常输出
   mov bh,0           ;显示页为0
   mov cx,1           ;显示字符为1个
   mov ah,09h
   int 10h            ;输出bl属性的字符串
   mov ah,03h
   int 10h             ;读光标位置
   inc dl             ;输出列+1
   mov ah,02h
   int 10h            ;置光标位置
   jmp L12
L11:
   mov bl,00000100b   ;bl属性为红色输出
   mov bh,0           ;显示页为0
   mov cx,1           ;显示字符个数为1个
   mov ah,09h
   int 10h            ;输出属性为bl的字符
   mov ah,03h
   int 10h            ;读光标位置
   inc dl              ;输出列+1
   mov ah,02h
   int 10h            ;置光标位置
L12:
  pop cx
  loop L9
  lea dx,crlf        ;输出后，回车换行
  mov ah,09
  int 21h
  
  ret
codes ends
end start
;
