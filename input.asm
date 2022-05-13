%include "common.inc"
%include "print.asm"

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
    dim_prompt: db "Matrix dimension: ", 0
    fmt_err_dim: db "Dimension must be between %d-%d inclusive!", 10, 0

section .text
; in: void
; out: mat_dim
fn_input_dim:
    prologue

    ; input mat_dim
    mov rdi, dim_prompt
    xor eax, eax
    call printf wrt ..plt
    mov rdi, scanf_int_fmt
    mov rsi, dim_ptr
    call scanf wrt ..plt

    mov eax, dword [dim_ptr]    ; eax = dim_val
    cmp eax, min_dim            ; check dim_val < min_dim
    jl .input_err               ; if true, goto .input_err
    cmp eax, max_dim            ; check dim_val <= max_dim
    jle .exit                   ; if true, goto .exit

.input_err:
    mov rdi, fmt_err_dim
    mov rsi, min_dim
    mov rdx, max_dim
    xor eax, eax
    call printf wrt ..plt
    mov rax, -1

.exit:
    epilogue
    ret

section .data
    row_prompt: db "Elements of row #%d: ", 0

section .text
; in: row_ptr, row_dim, row_index
; out: void
fn_input_row:
    prologue
    save r12, r13, r14
    sub rsp, 8                  ; align stack

    mov r12, rdi                ; r12 = row_ptr
    mov r13, rsi                ; r13 = row_dim
    mov rsi, rdx                ; 2nd arg (row_index) to printf
    add rsi, 1                  ; rsi = row_index + 1
    mov rdi, row_prompt         ; 1st arg to printf
    xor eax, eax                ; no vector registers
    call printf wrt ..plt       ; call printf
    mov r14, 0                  ; r14 = elem_index

.loop:
    mov rdi, scanf_double_fmt   ; first arg to scanf
    lea rsi, [r12 + r14 * 8]    ; rsi = elem_ptr = row_ptr + (8 * elem_index)
    xor eax, eax                ; no vector register
    call scanf wrt ..plt        ; input elem_val; row_ptr[rsi] = elem_val
    add r14, 1                  ; increase elem_index
    cmp r13, r14                ; if row_n > elem_index
    jg .loop                    ; then goto .loop

.exit:
    add rsp, 8
    restore r14, r13, r12
    epilogue
    ret

; in: mat_dim
; out: mat_ptr
fn_input_matrix:
    prologue
    save r12, r13, r14, r15

    mov r12, rdi            ; r12 = mat_dim
    imul rdi, rdi           ; rdi *= rdi = pow(mat_dim, 2)
    shl rdi, 3              ; rdi *= 8 = mat_size (in bytes)
    call malloc wrt ..plt   ; allocate buffer for matrix, mat_ptr in eax
    mov r13, rax            ; r13 = mat_ptr
    lea r14, [r12 * 8]      ; r14 = row_size (in bytes)
    mov r15, 0              ; r15 = row_index

.loop:
    mov rax, r15
    imul rax, r14
    lea rdi, [r13 + rax]    ; rdi = row_ptr
    mov rsi, r12            ; rsi = row_dim
    mov rdx, r15            ; rdx = row_index
    call fn_input_row       ; input an entire row
    add r15, 1              ; increase row_index
    cmp r12, r15            ; if mat_dim > row_index
    jg .loop                ; then goto .loop

.exit:
    mov rax, r13
    restore r15, r14, r13, r12
    epilogue
    ret

main:
    prologue
    call fn_input_dim           ; input mat_dim
    cmp rax, -1                 ; if mat_dim invalid
    je .exit                    ; then goto .exit

    mov rdi, rax                ; rdi = mat_dim
    call fn_input_matrix        ; input matrix

.print_matrix:
    mov rdi, rax                ; rdi = mat_ptr
    mov esi, dword [dim_ptr]    ; esi = mat_dim
    call fn_print_matrix        ; print the matrix

.exit:
    xor eax, eax
    epilogue
    ret
