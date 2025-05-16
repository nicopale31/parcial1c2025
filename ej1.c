extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
    sleep_name:    db "sleep", 0
    wakeup_name:   db "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE

;########### OFFSETS Y TAMAÑO DE LOS STRUCTS
; directory_entry_t {
;   char* name;             (offset 0)
;   void (*ptr)();          (offset 8)
; } (size = 16)
DIRENTRY_NAME_OFFSET      EQU 0
DIRENTRY_PTR_OFFSET       EQU 8
DIRENTRY_SIZE             EQU 16

; fantastruco_t {
;   directory_entry_t** __dir;      (offset 0)
;   uint16_t    __dir_entries;      (offset 8)
;   padding 6 bytes                 (offsets 10-15)
;   void*       __archetype;        (offset 16)
;   uint8_t     face_up;            (offset 24)
;   padding 7 bytes                 (offsets 25-31)
; } (size = 32)
FANTASTRUCO_DIR_OFFSET        EQU 0
FANTASTRUCO_ENTRIES_OFFSET    EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET  EQU 16
FANTASTRUCO_FACEUP_OFFSET     EQU 24
FANTASTRUCO_SIZE              EQU 32

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
        push    rbp
        mov     rbp, rsp
        push    rbx
        sub     rsp, 24
        mov     QWORD  [rbp-24], rdi
        mov     rax, QWORD  [rbp-24]
        mov     WORD  [rax+8], 2
        mov     rax, QWORD  [rbp-24]
        mov     QWORD  [rax+16], 0
        mov     rax, QWORD  [rbp-24]
        movzx   eax, WORD  [rax+8]
        movzx   eax, ax
        sal     rax, 3
        mov     rdi, rax
        call    malloc
        mov     rdx, rax
        mov     rax, QWORD  [rbp-24]
        mov     QWORD  [rax], rdx
        mov     rax, QWORD  [rbp-24]
        mov     rax, QWORD  [rax]
        test    rax, rax
        je      .L9
        mov     rax, QWORD  [rbp-24]
        mov     rbx, QWORD  [rax]
        mov     esi, OFFSET FLAT:sleep
        mov     edi, OFFSET FLAT:.LC0
        call    create_dir_entry
        mov     QWORD  [rbx], rax
        mov     rax, QWORD  [rbp-24]
        mov     rax, QWORD  [rax]
        lea     rbx, [rax+8]
        mov     esi, OFFSET FLAT:wakeup
        mov     edi, OFFSET FLAT:.LC1
        call    create_dir_entry
        mov     QWORD PTR [rbx], rax
        jmp     .L6
.L9:
        nop
.L6:
        mov     rbx, QWORD PTR [rbp-8]
        leave
        ret
; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
    push    rbp
    mov     rbp, rsp
    push    rbx
    sub     rsp, 16

    ; malloc(sizeof(fantastruco_t))
    mov     edi, FANTASTRUCO_SIZE
    call    malloc
    mov     rbx, rax            ; rbx = card*
    test    rbx, rbx
    je      .Lsummon_ret

    ; init_fantastruco_dir(card)
    mov     rdi, rbx
    call    init_fantastruco_dir

    ; card->face_up = TRUE
    mov     byte [rbx + FANTASTRUCO_FACEUP_OFFSET], TRUE
    mov     rax, rbx            ; return card*

.Lsummon_ret:
    add     rsp, 16
    pop     rbx
    pop     rbp
    ret

; Esqueleto main (no se usa en tests)
global main
main:
    push    rbp
    mov     rbp, rsp
    mov     eax, 0
    pop     rbp
    ret
