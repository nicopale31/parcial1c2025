extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.

	;
	; r/m64 = void*    card ; Vale asumir que card siempre es al menos un card_t*
	; r/m64 = char*    habilidad
	push rbp
	mov rbp, rsp 
	
	push r12 ; rdiFANTASTRUCO_DIR_OFFSET
	push r13 ; rsi
	push r14 ; cant entries (carta actual) 
	push r15 ; direntries
	push rbx ; i
	sub rsp, 8

	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15
	xor rbx, rbx

	mov r12, rdi
	mov r13, rsi
	
	

loop:

	cmp r12, 0
	je final

	mov r14w, WORD [r12 + FANTASTRUCO_ENTRIES_OFFSET]

loopinterno:
	
	cmp r14w, bx
	je siguientecarta

	mov r15, [r12 + FANTASTRUCO_DIR_OFFSET]
	mov rcx, [r15 + 8* rbx] ; directorio actual
	
	mov rdi, rcx
	mov rsi, r13
	
	push rcx
	sub rsp, 8
	call strcmp
	add rsp, 8
	pop rcx

	cmp eax, 0
	je llamarfuncionfinal

	inc rbx
	jmp loopinterno
	
	


siguientecarta:

	mov r12, [r12 + FANTASTRUCO_ARCHETYPE_OFFSET]
	
	xor rbx, rbx
	jmp loop


llamarfuncionfinal:
	mov rdi, r12
	call [rcx + DIRENTRY_PTR_OFFSET]


final:

	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12

	pop rbp
	ret ;No te olvides el ret!
