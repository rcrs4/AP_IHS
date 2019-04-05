org 0x7e00
jmp 0x0000:start

cadastrarc db  'Cadastrar Conta: 1',0dh,0x0a,0
buscarc db 'Buscar Conta: 2',0dh,0x0a,0
editarc db 'Editar Conta: 3',0dh,0x0a,0
deletarc db 'Deletar Conta: 4',0dh,0x0a,0
listara db 'Listar Agencia: 5',0dh,0x0a,0
listarcontasa db 'Listar Contas de uma Agencia: 6',0dh,0x0a,0
CadastrarNome db 'Coloque seu Nome:', 0dh,0x0a, 0
CadastrarCPF db 'Coloque seu CPF:', 0dh,0x0a, 0
CadastrarAgencia db 'Coloque o Codigo da Agencia:', 0dh,0x0a, 0
CadastrarConta db 'Coloque o numero da conta:', 0dh,0x0a, 0
inserirCPF db 'Insira o CPF:', 0dh, 0x0a, 0
readCharN:
	xor cx, cx
	start_readCharN:
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
		jmp start_readCharN
	end_readCharN:
		mov ah, 0Eh
		int 10h
		mov al, 0x0a
		mov ah, 0Eh
		int 10h
		mov al, 0
		stosb
ret

cadastro:
	push si 
	mov si, CadastrarNome
	call puts
	call readCharN
	call puts
	call readCharN
	call puts
	call readCharN
	call puts
	call readCharN
	pop si
	
ret

compara:
	lodsb
	mov dl, al
	mov al, bl
	add al, '0'
	mov ah, 0Eh
	int 10h
	mov al, byte[bx]
	inc bx
	cmp dl, al
	jne end_compara
	cmp al, 0
	je busca_end
	jmp compara
	end_compara:
	inc cx
ret
busca:
	xor cx, cx
	mov bx, di
	mov al, bl
	add al, '0'
	mov ah, 0Eh
	int 10h
	push di
	call readCharN
	pop di
	start_busca:
		cmp cx, 0
		jne passar
		mov ax, 100h
		mov si, ax
		push bx
		call compara
		pop bx
		jmp start_busca
	passar:
		lodsb
		cmp al, 0
		jne passar
		inc cx
		cmp cx, 4
		jne passar
		mov cx, 0
		jmp start_busca
	busca_end:
	call puts
	call puts
	call puts
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
		jne is_2
		call cadastro
		is_2:
			cmp al,"2"
			jne is_zero
			xor ax, ax
			call busca
	is_zero:
		cmp al, '0'
		je end
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
	mov bx, 100h
	mov ds, ax
	mov es, ax
	mov di, bx
	mov si, bx
	mov bx, ax
	
	call init
	while:
		call veriComando
	jmp while
end:
	call ler
	times 510-($-$$) db 0
	dw 0xaa55 
	