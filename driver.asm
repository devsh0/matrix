%include "header.inc"

section .data
    fmt_dim_eq: db 10, "mat1.dim == mat2.dim", 10, 0
    fmt_dim_neq: db 10, "mat1.dim != mat2.dim", 10, 0

section .text
    global main

main:
    sub rsp, 24

    call fn_input_matrix        ; input matrix
    test rax, rax
    jz .exit
    mov [rsp + 16], rax         ; [rsp + 16] = mat1_struct_ptr

    call fn_input_matrix
    test rax, rax
    jz .exit
    mov [rsp + 8], rax          ; [rsp + 8] = mat2_struct_ptr

    mov rdi, [rsp + 16]
    mov rsi, [rsp + 8]
    call fn_add_matrix
    test rax, rax
    jz .exit
    xor eax, eax

.exit:
    add rsp, 24
    ret
