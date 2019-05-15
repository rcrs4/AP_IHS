org 0x7e00
jmp 0x0000: start

cadastrarc db  'Cadastrar Conta: 0',0dh,0x0a,0
buscarc db 'Buscar Conta: 1',0dh,0x0a,0
deletarc db 'Deletar Conta: 2',0dh,0x0a,0
CadastrarNome db 'Coloque seu Nome:', 0dh,0x0a, 0
CadastrarCPF db 'Coloque seu CPF:', 0dh,0x0a, 0
CadastrarAgencia db 'Coloque o Codigo da Agencia:', 0dh,0x0a, 0
CadastrarConta db 'Coloque o numero da conta:', 0dh,0x0a, 0
deleteok db 'Deletado com sucesso', 0dh, 0x0a, 0
nomeBusca db 'Coloque o nome para buscar conta: ', 0dh, 0x0a, 0
delUser db 'Coloque o nome para deletar conta: ', 0dh, 0x0a, 0
Func db 'Coloque a funcao desejada: ', 0dh,0x0a, 0

del:
	LD:
		lodsb
		cmp al, 0
		je end_del
		mov al, ' '
		stosb
		jmp LD
	end_del:
ret	

compara:
	lodsb;carrega de si
	mov dl, al
	mov al, byte[bx];carrega de di
	inc bx;aumenta o bx pra percorrer o ponteiro
	cmp dl, al;compara 
	jne end_compara;se for diferente sai da funcao
	cmp al, 0;se for igual e al eh "0"(final da string) vai pra saida como nome igual
	je end_compara_ok
	jmp compara
	end_compara_ok:
		mov ax, 1000h;bota ax como parametro de retorno
	end_compara:
ret

busca:; a busca eh um pouco mais complexa guardei o numero de di antes de pegar o nome do cadastro em bx pra poder sempre retornar nele
	xor cx, cx
	mov bx, di
	push di;dei push pra ter uma continuacao ao dar novo cadastro, nao perder o ponteiro pra o ultimo cadastro realizado
	push ax
	call readCharN;le nome que quer procurar
	pop ax 
	pop di
	mov ax, 200h;seta si pro começo dos cadastros so por garantia
	mov si, ax
	start_busca:
		cmp si, di
		je end_busca
		push bx;guarda o valor do comeco do nome a procurar
		push si
		call compara
		pop si
		pop bx
		cmp ax, 1000h;ve se deu certo ou nao
		je busca_end
		mov cx, 0
	passar:;caso eh nome diferente passa todo o cadastro
		lodsb
		cmp al, 0
		jne passar
		inc cx
		cmp cx, 4;sao 4 componentes em cada cadastro
		jne passar
		mov cx, 0
		jmp start_busca
	busca_end:
	end_busca:
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

cadastro:;le o nome e o cpf etc bota na memoria na posicao guardada pelo "di" com a funcao stosb
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

string db 'AP2 de IHS', 0

interrupt20h:
	
	is_1:
		cmp al, '1'
		jne is_2
		call cadastro
		jmp end_int20
	is_2:
		cmp al, '2'
		jne is_3
		mov si, nomeBusca
		call puts
		call busca
		mov cx, 4
		cmp ax, 1000h
		jne end_int20
		Lp:
			call puts
			mov al, 0x0a
			mov ah, 0xe
			int 10h
		loop Lp
		jmp end_int20
	is_3:
		cmp al, '3'
		jne end_int20
		mov si, delUser
		call puts
		push di
		call busca
		cmp ax, 1000h
		jne end3
		mov di,si 
		call del
		mov si, deleteok
		call puts
		end3:
			pop di
	end_int20:
iret


interrupt40h:
  lodsb
  cmp al, 0
  je end_int
  call putchar
  jmp interrupt40h
  end_int:
iret

putchar:
    mov ah, 0eh
    int 10h
ret

start:
    xor ax, ax
	mov cx, ax
	mov bx, 200h;inicia com 100h pq eh uma boa posicao de memoria nao invade nada ate onde testei
	mov ds, ax
	mov es, ax
	mov di, bx
	mov si, bx
	mov bx, ax
	mov si, string
	
	push ds
	mov ax, 0
	mov ds, ax
	mov di, 100h
	mov word[di], interrupt40h
	mov word[di+2], 0h
	pop ds
	 
	push ds
	mov ax, 0
	mov ds, ax
	mov di, 80h
	mov word[di], interrupt20h
	mov word[di+2], 0h
	pop ds
	
	mov di, 200h
	while:
		mov si, Func
		call puts
		mov ah, 0h
		int 16h
		cmp al, '0'
		je end
		int 20h
	jmp while
end:
dw 0xaa55
