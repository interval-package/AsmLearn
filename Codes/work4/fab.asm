assume cs:code,ds:data,ss:stack

stack segment
    dw 256 dup(0)
stack ends


code segment
    start:
        mov ax, data    ; init regs
        mov ds, ax
        mov ax, stack
        mov ss, ax
        mov sp, 256

    call fab_inputf

    call fab_recur

    call input_next
    jne start

    ending:
        mov ax, 4c00h
        int 21H


fab_recur proc far
    ; we assume get al input

    mov dx, 0h
    mov ax, 1h

    push dx
    push dx
    push dx
    push dx
    push dx
    push dx
    push ax
    push ax

    mov ax, N
    mov cx, ax
    sub cx, 2

    fab_looping:
        ; using bx to cache the cx
        mov bx, cx

        mov di, 0
        mov cx, 4
        stack_loop:
            ; ax store the low
            pop ax
            ; dx store the high
            pop dx
            adc ax, dx
            mov temp_new[di], ax
            mov temp_old[di], dx
            inc di
            inc di
        loop stack_loop

        mov cx, 4
        restack_loop:
            dec di
            dec di
            push temp_new[di]
            push temp_old[di]
        loop restack_loop

        mov cx, bx
    loop fab_looping

    lea ax, msg_output
    call printf

    mov bx, 8
    mov cx, 4
    clean_loop:
        pop ax
        pop ax
        sub bx, 2
        ; call disp_num
        mov dx, temp_new[bx]
        mov al, dh
        call disp_hex
        mov al, dl
        call disp_hex
    loop clean_loop

    mov dl, 'H'
    mov ah, 02h
    int 21H

    lea dx, CRLF
    mov ax, 0900h
    int 21H

    mov ax, temp_new
    call disp_num

    retf
fab_recur endp

fab_inputf proc far
    lea dx, msg_input
    mov ax, 0900h
    int 21H

    lea dx, input_data
    mov ah, 0AH
    int 21H

    mov di, 0
    mov al, input_data+1
    mov ah, 0
    mov cx, ax
    mov dx, 0
    mov ax, 0

    input_loop:
        mov dl, input_data[di+2]
        sub dl, '0'
        mul ten
        add al, dl
        inc di
    loop input_loop
    
    mov ah, 0
    mov N, ax
    retf
fab_inputf endp

printf proc far
    push dx
    mov dx, ax 
    mov ax, 0900h
    int 21H

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    pop dx
    retf
printf endp

input_next proc far
    ; judge the input of the char, and decide next action

    lea ax, input_msg_next
    call printf

    mov ah, 08h
    int 21H

    cmp al, 'q'
    retf
input_next endp

de_disp proc far
    mov dl, '0'
    mov ah, 02h
    int 21H
    retf
de_disp endp

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

disp_hex proc far
    push cx
    push si
    push dx
    push ax

    ; input with al
    ; this proc attempt to disp a specific num
    mov si, 0h
    num_div:
        mov ah, 0h

        div sixteen
        push ax
        inc si

        cmp al, 0h
        jne num_div

    mov cx, si
    _disp_1:
        pop dx
        mov dl, dh
        cmp dl, 9
        jna unadd_7
        add dl, 7
        unadd_7:
            add dl, '0'
            mov ah, 02h
            int 21H
            loop _disp_1

    mov dl, ' '
    mov ah, 02h
    int 21H

    pop ax
    pop dx
    pop si
    pop cx
    retf
disp_hex endp

code ends


DATA SEGMENT
    input_msg_next db "Input q to quit", '$'
    msg_input DB 13,10,"Please input the num of Fibonacci, no lager than 256, N =", '$'
    msg_output DB 13,10,"Fibonacci Sequence is:", '$'    ;提示信息

    CRLF DB 0AH, 0DH,'$' 
    ten db 10
    sixteen db 16

    input_data db 3
    db ?
    db 16 dup(0), '$'

    N DW 0
    temp_new dw 4 dup(0h)
    temp_old dw 4 dup(0h)
DATA ENDS

end start