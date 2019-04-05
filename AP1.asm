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
	call readCharN;le nome que quer procurar 
	pop di
	mov ax, 100h;seta si pro começo dos cadastros so por garantia
	mov si, ax
	start_busca:
		push bx;guarda o valor do comeco do nome a procurar
		call compara
		pop bx
		cmp ax, 1000h;ve se deu certo ou nao
		je busca_end
		mov cx, 0
	passar:;caso eh nome diferente passa todo o cadastro
		lodsb
		cmp al, 0
		jne passar
		mov ah, 0Eh
		int 10h
		inc cx
		cmp cx, 4;sao 4 componentes em cada cadastro
		jne passar
		mov cx, 0
		jmp start_busca
	busca_end:
	call puts
	mov al, 0x0a
	mov ah, 0xe
	int 10h
	call puts
	mov al, 0x0a
	mov ah, 0xe
	int 10h
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
	start_comando:;pega um caractere e ve qual eh o comando
		cmp al, "1"
		jne is_2
		call cadastro
		is_2:
			cmp al,"2"
			jne is_zero
			xor ax, ax;nao lembro pra que isso, mas acho q nao eh nada
			call busca
			jmp end_veri
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
	mov bx, 100h;inicia com 100h pq eh uma boa posicao de memoria nao invade nada ate onde testei
	mov ds, ax
	mov es, ax
	mov di, bx
	mov si, bx
	mov bx, ax
	
	call init;so pra modularizar, inicia o menu
	while:;loop infinito ate o usuario apertar "0"
		call veriComando
	jmp while
end:
	call ler

	