org 0x7e00
jmp start

cadastrarc db  'Cadastrar Conta: 1',0dh,0x0a,0
buscarc db 'Buscar Conta: 2',0dh,0x0a,0
editarc db 'Editar Conta: 3',0dh,0x0a,0
deletarc db 'Deletar Conta: 4',0dh,0x0a,0
listara db 'Listar Agencia: 5',0dh,0x0a,0
listarcontasa db 'Listar Contas de uma Agencia: 6',0dh,0x0a,0
CadastrarNome db 'Coloque seu Nome:', 0dh,0x0a, 0
readCharN:
	mov ah, 0h
	int 16h
	inc cx
	cmp al, 0Dh
	je end_readCharN
	cmp cx, 20
	jge end_readCharN
	mov ah, 0Eh
	int 10h
	stosb
	jmp readCharN
	end_readCharN:
		mov al, 0
		stosb
ret

cadastro:
	call readCharN
ret

ler:
	lodsb
	cmp si, di
	je end_ler
	mov ah, 0xe
	int 10h
	jmp ler
	end_ler:
ret

puts:
    lodsb
	cmp al, 0
	je end_puts
	mov ah, 0xe
	int 10h
    jmp puts
	end_puts:
		mov al, 0Dh
		mov ah, 0xe
		int 10h
ret

veriComando:
	mov ah, 0h
	int 16h
	start_comando:
		cmp al, "1"
		jne end_veri
		push si
		mov si, CadastrarNome
		call puts
		pop si
		call cadastro
	end_veri:
ret

init:
	push si
	mov si, cadastrarc
	mov cx, 6
	L1:
		call puts
	loop L1
	pop si
ret

start:
	xor ax, ax
	mov cx, ax
	mov bx, ax
	mov ds, ax
	mov es, ax
	call init
	call veriComando

end:
	times 510-($-$$) db 0
	dw 0xaa55 
	