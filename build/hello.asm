DATA   SEGMENT                               ;定义数据段
PRINT  DB "Hello World!", 0AH, 0DH, '$'      ;定义一个字符串，以'$'结束
DATA   ENDS                                  ;定义数据段结束
STACK  SEGMENT   STACK                       ;定义堆栈段 
       DW  20  DUP(0)                        ;为堆栈段分配空间
STACK  ENDS                                  ;定义堆栈段结束
CODE   SEGMENT                               ;定义代码段
ASSUME CS:CODE, DS:DATA, SS:STACK            ;告诉编译器将段寄存器与符号对应起来
START:                                       ;程序入口
        MOV AX, DATA                         
        MOV DS, AX                           ;将段地址DATA送入DS中
        MOV DX, OFFSET  PRINT                ;将字符串地址送人DX中
        MOV AH, 09H
        INT 21H                              ;调用INT 21H的9号中断
        MOV AH, 4CH                          ;返回DOS系统
        INT 21H
CODE   ENDS                                  ;定义代码段结束
END    START                                 ;程序结束