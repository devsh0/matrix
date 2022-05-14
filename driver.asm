%include "common.asm"
%include "input.asm"
%include "print.asm"

section .text
    default rel
    global main

main:
    prologue
    mov rdi, rax                ; rdi = mat_dim
    call fn_input_matrix        ; input matrix

    mov rdi, rax                ; rdi = mat_struct_ptr
    call fn_print_matrix        ; print the matrix

.exit:
    xor eax, eax
    epilogue
    ret
