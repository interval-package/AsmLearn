DATA   SEGMENT                               
INPUT  DB  "Please input a string: ",'$'
OUTPUT DB  "Your input is: ",'$'
BUFFER DB  20				    ;预定义20字节的空间
       DB  ?				    ;待输入完成后，自动获得输入的字符个数
       DB  20  DUP(0)    
CRLF   DB  0AH, 0DH,'$'                   
DATA   ENDS                                  
STACK  SEGMENT   STACK                       
       DW  20  DUP(0)                      
STACK  ENDS                                  
CODE   SEGMENT                              
ASSUME CS:CODE, DS:DATA, SS:STACK            
START:                                       
        MOV AX, DATA                         
        MOV DS, AX                      
        LEA DX, INPUT                        ;打印提示输入信息    
        MOV AH, 09H							 
        INT 21H
        LEA DX,BUFFER                        ;接收字符串
        MOV AH, 0AH
        INT 21H
        MOV AL, BUFFER+1                     ;对字符串进行处理
        ADD AL, 2
        MOV AH, 0
        MOV SI, AX
        MOV BUFFER[SI], '$'
        LEA DX, CRLF                         ;另取一行                   
        MOV AH, 09H							 
        INT 21H
        LEA DX, OUTPUT                       ;打印提示输出信息
        MOV AH, 09H							 
        INT 21H
        LEA DX, BUFFER+2                     ;输出输入的字符串
        MOV AH, 09H							 
        INT 21H
        LEA DX, CRLF                         ;另取一行                  
        MOV AH, 09H							 
        INT 21H
 
        MOV AH, 4CH                          ;返回DOS系统
        INT 21H
CODE   ENDS                                  
END    START                                 