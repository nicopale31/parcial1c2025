extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0      ; offset 0 bytes dentro de directory_entry_t para ability_name
DIRENTRY_PTR_OFFSET  EQU 16     ; offset 16 bytes para ability_ptr
DIRENTRY_SIZE       EQU 24      ; tamaño total directory_entry_t (10 + padding hasta 24)

FANTASTRUCO_DIR_OFFSET     EQU 0    ; offset 0 para __dir dentro card_t o fantastruco_t
FANTASTRUCO_ENTRIES_OFFSET EQU 8    ; offset 8 para __dir_entries (uint16_t, 2 bytes, pero ocupa 8 bytes por alineación)
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16 ; offset 16 para __archetype (puntero)
FANTASTRUCO_FACEUP_OFFSET  EQU 24   ; offset 24 para bool face_up (en fantastruco_t)
FANTASTRUCO_SIZE           EQU 32   ; tamaño total de fantastruco_t (aprox)

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
mensaje_sleep: db "Habilidad: sleep", 0

section .text

; void invocar_habilidad(void* carta, char* habilidad);
; Entrada: 
;   rdi = carta (void*)
;   rsi = habilidad (char*)
invocar_habilidad:
    push    r14
    mov     r14, rdi            ; r14 = carta
    push    r13
    push    r12
    mov     r12, rsi            ; r12 = habilidad
    push    rbp
    push    rbx

.L5:
    movzx   eax, WORD [r14 + FANTASTRUCO_ENTRIES_OFFSET] ; eax = carta->__dir_entries (uint16_t)
    test    ax, ax
    je      .L2

    mov     rbx, [r14 + FANTASTRUCO_DIR_OFFSET]          ; rbx = carta->__dir (directory_t)
    lea     r13, [rbx + rax*8]                           ; r13 = &carta->__dir[carta->__dir_entries] (final)

.L4:
    mov     rbp, [rbx]                                   ; rbp = carta->__dir[i] (directory_entry_t*)
    mov     rsi, r12                                     ; argumento habilidad (char*)
    mov     rdi, rbp                                     ; argumento entrada->ability_name (char*)
    call    strcmp
    test    eax, eax
    jne     .L3                                          ; si strcmp != 0, continuar ciclo

    ; strcmp == 0, se encontró la habilidad
    pop     rbx
    mov     rax, [rbp + DIRENTRY_PTR_OFFSET]             ; rax = entrada->ability_ptr
    mov     rdi, r14                                     ; pasar carta como argumento a la habilidad
    pop     rbp
    pop     r12
    pop     r13
    pop     r14
    jmp     rax                                         ; llamar a la función habilidad

.L3:
    add     rbx, 8                                       ; siguiente entrada (puntero a directory_entry_t*)
    cmp     rbx, r13
    jne     .L4                                          ; repetir ciclo

.L2:
    mov     r14, [r14 + FANTASTRUCO_ARCHETYPE_OFFSET]    ; carta = carta->__archetype
    test    r14, r14
    jne     .L5                                          ; si arquetipo != NULL, buscar ahí

    pop     rbx
    pop     rbp
    pop     r12
    pop     r13
    pop     r14
    ret
