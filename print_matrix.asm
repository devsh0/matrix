section .data
element_fmt: db "%.3f", 9, 0

section .text
; (row_base_ptr, row_size) ret void
fn_print_row:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi        ; row_base_ptr into r12 = 0x405ac0
    mov r13, rsi        ; row_size into r13
    mov r14, 0          ; element_index counter

.loop:
    mov rdi, element_fmt
    lea rsi, [r12 + (r14 * 8)]
    movsd xmm0, [rsi]
    mov eax, 1
    call printf wrt ..plt
    add r14, 1
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
line_feed: db 10, 0

fn_print_newline:
    sub rsp, 8
    mov rdi, line_feed
    xor eax, eax
    call printf wrt ..plt
    add rsp, 8
    ret

section .text
; (matrix_base_ptr, matrix_size) ret void
fn_print_matrix:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                ; matrix_base_ptr into r12
    mov r13, rsi                ; row_size into r13
    lea r15, [r13 * 8]          ; row_size_in_bytes
    mov r14, 0                  ; row_index into r14
    mov rdi, r13

    call fn_print_newline

.loop:
    mov rdi, r15
    imul rdi, r14
    add rdi, r12
    mov rsi, r13
    call fn_print_row
    add r14, 1
    call fn_print_newline
    cmp r13, r14
    jg .loop

.exit:
    xor eax, eax
    pop r15
    pop r14
    pop r13
    pop r12
    mov rsp, rbp
    pop rbp
    ret
