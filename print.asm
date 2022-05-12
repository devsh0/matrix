%ifndef __PRINT__
    %define __PRINT__
    %include "common.inc"

    section .data
        fmt_int: db "int value = %llu", 10, 0
        fmt_float: db "float value = %f", 10, 0

    section .text
    ; in: integer value
    ; out: none
    fn_print_int:
        prologue
        mov rcx, rdi
        mov rdi, fmt_int
        mov rsi, rcx
        xor eax, eax
        call printf wrt ..plt
        xor eax, eax
        epilogue
        ret

    ; in: floating-point value
    ; out: none
    fn_print_double:
        prologue
        mov rcx, rdi
        mov rdi, fmt_float
        movsd xmm0, [rcx]
        mov eax, 1
        call printf wrt ..plt
        xor eax, eax
        epilogue
        ret

    section .data
        fmt_element: db "%.3f", 9, 0

    section .text
    ; in: row_base_ptr, row_size
    ; out: none
    fn_print_row:
        prologue
        save r12, r13, r14
        sub rsp, 8

        mov r12, rdi        ; row_base_ptr into r12 = 0x405ac0
        mov r13, rsi        ; row_size into r13
        mov r14, 0          ; element_index counter

    .loop:
        mov rdi, fmt_element
        lea rsi, [r12 + r14 * 8]
        movsd xmm0, [rsi]
        mov eax, 1
        call printf wrt ..plt
        add r14, 1
        cmp r13, r14
        jg .loop

        xor eax, eax
        add rsp, 8
        restore r14, r13, r12
        epilogue
        ret

    section .data
        line_feed: db 10, 0

    fn_print_newline:
        prologue
        mov rdi, line_feed
        xor eax, eax
        call printf wrt ..plt
        epilogue
        ret

    section .text
    ; in: matrix_base_ptr, matrix_size
    ; out: none
    fn_print_matrix:
        prologue
        save r12, r13, r14, r15

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
        restore r15, r14, r13, r12
        epilogue
        ret
%endif
