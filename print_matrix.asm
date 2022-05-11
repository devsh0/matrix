section .data
element_fmt: db "%f ", 0

section .text
; (row_base_ptr, row_size) ret void
fn_print_row:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi        ; row_base_ptr into r12
    mov r13, rsi        ; row_size into r13
    mov r14, 0          ; element_index counter

.loop:
    mov rdi, element_fmt
    lea rsi, [r12 + r14 * 8]
    xor eax, eax
    call printf wrt ..plt
    cmp r13, r14
    jg .loop

    xor eax, eax
    add rsp, 8
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret

section .data
line_feed: db "%s", 0

section .text
; (matrix_base_ptr, matrix_size) ret void
fn_print_matrix:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi                ; matrix_base_ptr into r12
    mov r13, rsi                ; row_size into r13
    mov r14, 0                  ; row_index into r14
    mov rdi, r13

.loop:
    imul rdi, 8                 ; row_size_in_bytes
    imul rdi, r14
    add rdi, r12                ; row_base_ptr
    mov rsi, r13
    call fn_print_row
    add r14, 1
    cmp r13, r14

.print_line_feed:
    mov rdi, line_feed
    mov rsi, 10
    xor eax, eax
    call printf wrt ..plt
    jg .loop

.exit:
    xor eax, eax
    add rsp, 8
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret
