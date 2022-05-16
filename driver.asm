%include "header.inc"

section .data
    fmt_dim_eq: db 10, "mat1.dim == mat2.dim", 10, 0
    fmt_dim_neq: db 10, "mat1.dim != mat2.dim", 10, 0

section .text
    global main

fn_test_add:
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

    mov rdi, rax
    call fn_print_matrix

.exit:
    add rsp, 24
    ret

fn_test_scale:
    sub rsp, 8
    call fn_input_matrix

    mov rdi, rax
    mov qword [rsp], -1
    cvtsi2sd xmm0, qword [rsp]
    call fn_scale_matrix

    mov rdi, rax
    call fn_print_matrix

.exit:
    add rsp, 8
    ret

fn_test_subtract:
    sub rsp, 8

    call fn_input_matrix
    mov [rsp], rax
    call fn_input_matrix

    mov rdi, [rsp]
    mov rsi, rax
    call fn_subtract_matrix

    test eax, eax
    jz .exit

    mov rdi, rax
    call fn_print_matrix

.exit:
    add rsp, 8
    ret

fn_test_dotprod:
    sub rsp, 8
    call fn_input_matrix
    mov [rsp], rax
    call fn_input_matrix

    mov rsi, rax
    mov rdi, [rsp]
    call fn_dotprod_matrix
    test rax, rax
    jz .exit
    mov rdi, rax
    call fn_print_matrix

.exit:
    add rsp, 8
    ret

main:
    sub rsp, 8
    call fn_test_dotprod

.exit:
    add rsp, 8
    ret
