;********************************
datarea  segment
    mess db  'string?',13,10,'$'
    letter   dw  0
    digit   dw  0
    other   dw  0                   
    monin label byte                      ;初始化输入缓冲区
    max db  81
    act db  ?
    mon db  81 dup(?)
 
datarea ends

program  segment
 
  assume cs:program,ds:datarea,es:datarea
start:
    push ds
    sub  ax, ax
    push ax
    mov  ax, datarea
    mov  ds, ax

    mov  letter, 0
    mov  digit, 0
    mov  other, 0
    lea  dx,mess   ;显示输入提示
    mov  ah,09      
    int  21h
    lea  dx,monin   ;将输入内容的地址给dx
    mov  ah,0ah     ;键盘输入
    int  21h         
    mov  dl,13       ;回车
    mov  ah,02
    int  21h
    mov  dl,10        ;换行
    mov  ah,02
    int  21h
    ;cmp  act,0      ;输入为空则退出
    ;je  exit
    lea     si,mon
    sub     cx,cx
    sub     ax,ax
    mov  cl, act ;循环次数
 
compares:
    mov  al, [si] ;将其中的内容送给ax
    cmp  al, 48; 先和48较
    jl   oth   ;如果小于48则跳转到计算other的代码中去
    cmp  al, 57  ;如果大于48,再和57比较，如果小于等于去往digit
    jle   dig     
    cmp  al, 65  ;如果大于57，再和65比较，如果小于去往other
    jl   oth
    cmp  al, 90  ;如果大于65，再和90比较，如果小于去往letter
    jle   let
    cmp  al, 97  ;如果大于90和97比较，小于则跳往other
    jl      oth
    cmp     al,122;如果大于97，再和122比较，小于等于则跳转到letter 
    jle     let
    jmp     oth;如果大于122，则跳转到other
    let:
        inc  letter
        jmp  short change_addr
    dig:
        inc  digit
        jmp  short change_addr
    oth:
        inc  other
        jmp  short change_addr
 
change_addr:
    inc     si
    loop    compares   
    mov  ax, letter
    mov  dl, al
    add  dl, 30h  ;转换为asc码中的数字
    mov    ah,02h
    int  21h
    mov  dl, 20h ;输出空格
    mov  ah, 02h
    int  21h
    mov  ax, digit
    mov  dl, al
    add  dl, 30h
    mov    ah,02h
    int  21h
    mov  dl, 20h
    mov  ah, 02h
    int  21h
    mov  ax, other
    mov  dl, al
    add  dl, 30h
    mov    ah,02h
    int  21h
    mov  dl, 20h
    mov  ah, 02h
    int  21h

exit:    
    ret

program ends

end  start