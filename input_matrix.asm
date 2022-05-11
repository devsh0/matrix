section .bss
min_size: equ 1
max_size: equ 64
matrix_size: resd 4

section .data
scanf_int_fmt: db "%d", 0
scanf_double_fmt: db "%f", 0

section .text
    default rel
    extern scanf
    extern printf
    extern malloc
    global main

section .data
fmt: db "value = %d", 10, 0

section .text
; (value) ret void
fn_print_int:
    push rbp
    mov rcx, rdi
    mov rdi, fmt
    mov rsi, rcx
    xor eax, eax
    call printf wrt ..plt
    xor eax, eax
    pop rbp
    ret

section .data
geometry: db "Enter size of the matrix: ", 0
err_geometry: db "Matrix size must be between %d-%d inclusive!", 10, 0

section .text
; (void) ret matrix_size
fn_input_matrix_geometry:
    push rbp
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
    pop rbx
    ret

section .data
row_input_prompt: db "Input elements of row #%d: ", 0

section .text
; (row_base_ptr, row_size, row_index) ret void
fn_input_row:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8                  ; align stack

    mov r12, rdi                ; row_base_ptr into r12d
    mov r13d, esi               ; row_size into r13d
    mov rsi, rdx                ; 2nd arg to printf
    add rsi, 1                  ; rsi = row_index + 1
    mov rdi, row_input_prompt   ; 1st arg to printf
    xor eax, eax                ; no vector registers
    call printf wrt ..plt       ; call printf
    mov r14d, 0                 ; element_index into r14d

.input_loop:
    mov rdi, scanf_double_fmt   ; first arg to scanf
    lea rsi, [r12 + r14 * 8]  ; element_ptr(rsi) = row_base_ptr + (8 * element_index)
    xor eax, eax                ; no vector register
    call scanf wrt ..plt        ; call scanf
    add r14d, 1                 ; increase element_index
    cmp r13d, r14d              ; check row_size > element_index
    jg .input_loop              ; jmp .input_loop if true

    add rsp, 8
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret

; (matrix_size) ret matrix_ptr
fn_input_matrix:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12d, edi    ; matrix_size = row_size into r12d
    imul edi, edi
    imul edi, 8
    mov esi, edi
    mov edi, scanf_int_fmt
    call malloc wrt ..plt

    mov r13, rax            ; load matrix_base_ptr into r13d
    lea r14d, [r12d * 8]    ; load row_size (in bytes) into r14d
    mov r15d, 0             ; load row_index into stack

.loop:
    mov eax, r15d
    imul eax, r14d
    lea rdi, [r13 + rax]    ; row_base_ptr into edi
    mov esi, r12d           ; row_size into esi
    mov edx, r15d
    call fn_input_row
    add r15d, 1
    cmp r12d, r15d
    jg .loop

.exit:
    pop r15
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp

    call fn_input_matrix_geometry
    cmp rax, -1
    je .input_error
    mov rdi, rax
    call fn_input_matrix
    ; Then what?
    jmp .exit

.input_error:
    mov rax, 1

.exit:
    xor eax, eax
    add rsp, 8
    ret
