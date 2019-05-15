org 0x500
jmp 0x0000:start

clear:
	mov dx, 0
    mov bh, 0      
    mov ah, 0x2
    int 10h
  
    mov cx, 2000 
    mov bh, 0
    mov al, 0x20 
    mov ah, 0x9
    int 10h
    
ret

temp: 
	mov bp, dx
	temp_:
	dec bp
	nop
	jnz temp_
	dec dx
	cmp dx,0    
	jne temp_
ret

start:	
    xor ax, ax
    mov ds, ax
    mov es, ax
    xor cx, cx

    mov bl, 3
    call clear

    mov ax, 0x7e0 ;0x7e0<<1 = 0x7e00 (início de kernel.asm)
    mov es, ax
    xor bx, bx    ;posição es<<1+bx

    jmp reset

reset:
    mov ah, 00h ;reseta o controlador de disco
    mov dl, 0   ;floppy disk
    int 13h

    jc reset    ;se o acesso falhar, tenta novamente

    jmp load

load:
    mov ah, 02h ;lê um setor do disco
    mov al, 20  ;quantidade de setores ocupados pelo kernel
    mov ch, 0   ;track 0
    mov cl, 3   ;sector 3
    mov dh, 0   ;head 0
    mov dl, 0   ;drive 0
    int 13h

    jc load     ;se o acesso falhar, tenta novamente

    jmp 0x7e00  ;pula para o setor de endereco 0x7e00 (start do boot2)
