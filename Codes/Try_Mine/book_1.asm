ASSUME CS:codesg

codesg segment
	
	MOV ax, 0123H
	MOV BX, 0456H
	ADD ax, bx

	mov ax, 4c00H
	int 21H

codesg ends

END