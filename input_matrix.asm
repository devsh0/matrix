%include "common.asm"
%include "print_matrix.asm"

section .bss
min_size: equ 1
max_size: equ 64
matrix_size: resd 4

section .data
scanf_int_fmt: db "%d", 0
scanf_double_fmt: db "%lf", 0

section .text
    default rel
    extern scanf
    extern printf
    extern malloc
    global main

section .data
geometry: db "Enter size of the matrix: ", 0
err_geometry: db "Matrix size must be between %d-%d inclusive!", 10, 0

section .text
; (void) ret matrix_size
fn_input_matrix_geometry:
    prologue
    mov rdi, geometry
    xor eax, eax
    call printf wrt ..plt
    mov rdi, scanf_int_fmt
    mov rsi, matrix_size
    call scanf wrt ..plt
    mov eax, dword [matrix_size]
    cmp eax, min_size
    jl .input_err
    cmp eax, max_size
    jle .exit

.input_err:
    mov rdi, err_geometry
    mov rsi, min_size
    mov rdx, max_size
    xor eax, eax
    call printf wrt ..plt
    mov rax, -1

.exit:
    epilogue
    ret

section .data
row_input_prompt: db "Input elements of row #%d: ", 0

section .text
; (row_base_ptr, row_size, row_index) ret void
fn_input_row:
    prologue
    save r12, r13, r14
    sub rsp, 8                  ; align stack

    mov r12, rdi                ; row_base_ptr into r12
    mov r13, rsi                ; row_size into r13
    mov rsi, rdx                ; 2nd arg to printf
    add rsi, 1                  ; rsi = row_index + 1
    mov rdi, row_input_prompt   ; 1st arg to printf
    xor eax, eax                ; no vector registers
    call printf wrt ..plt       ; call printf
    mov r14, 0                  ; element_index into r14

.input_loop:
    mov rdi, scanf_double_fmt   ; first arg to scanf
    lea rsi, [r12 + (r14 * 8)]    ; element_ptr(rsi) = row_base_ptr + (8 * element_index)
    xor eax, eax                ; no vector register
    call scanf wrt ..plt        ; call scanf
    add r14, 1                  ; increase element_index
    cmp r13, r14                ; check row_size > element_index
    jg .input_loop              ; jmp .input_loop if true

.exit:
    add rsp, 8
    restore r14, r13, r12
    epilogue
    ret

; (matrix_size) ret matrix_ptr
fn_input_matrix:
    prologue
    save r12, r13, r14, r15

    mov r12, rdi    ; matrix_size = row_size into r12
    imul rdi, rdi
    imul rdi, 8
    call malloc wrt ..plt
    mov r13, rax            ; load matrix_base_ptr into r13
    lea r14, [r12 * 8]      ; load row_size (in bytes) into r14
    mov r15, 0              ; load row_index into r15

.loop:
    mov rax, r15
    imul rax, r14
    lea rdi, [r13 + rax]    ; row_base_ptr into rdi
    mov rsi, r12            ; row_size into rsi
    mov rdx, r15
    call fn_input_row
    add r15, 1
    cmp r12, r15
    jg .loop

.exit:
    mov rax, r13
    restore r15, r14, r13, r12
    epilogue
    ret

main:
    prologue
    call fn_input_matrix_geometry
    cmp rax, -1
    je .exit
    mov rdi, rax
    call fn_input_matrix

.print_the_matrix:
    mov rdi, rax
    mov esi, dword [matrix_size]
    call fn_print_matrix

.exit:
    xor eax, eax
    epilogue
    ret
