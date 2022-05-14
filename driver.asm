%include "header.inc"

section .text
    global main

main:
    push rbx
    call fn_input_matrix        ; input matrix
    test eax, eax
    jnz .print
    mov eax, 1
    jmp .exit

.print:
    mov rbx, rax                ; allocate matrix; rbx = mat_struct_ptr
    mov rdi, rbx                ; rdi = mat_struct_ptr
    call fn_print_matrix        ; print the matrix

    mov rdi, rbx                ; rdi = mat_struct_ptr
    call fn_free_matrix         ; free matrix
    xor eax, eax

.exit:
    pop rbx
    ret
