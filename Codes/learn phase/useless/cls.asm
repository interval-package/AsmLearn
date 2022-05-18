; uses reg֮ must have spaces between
cls proc uses ax es si cx dx

	mov dx, 0b800h
	mov es, dx
	mov si, 0
	mov dx, 0
	mov cx, 4000

_cls_loop:
	mov es:[si],dx
	add si, 2
	loop _cls_loop

	mov ah, 2
	mov bh, 0
	mov dh, 5
	mov dl, 12
	int 10h

	ret
cls endp