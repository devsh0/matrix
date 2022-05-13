%ifndef __PRINT__
    %define __PRINT__
    %include "common.inc"

    section .data
            line_feed: db 10, 0

    section .text
    fn_print_newline:
        prologue
        mov rdi, line_feed
        xor eax, eax
        call printf wrt ..plt
        epilogue
        ret

    section .data
        fmt_int: db "int value = %llu", 10, 0
        fmt_float: db "float value = %f", 10, 0

    section .text
    ; in: int_val
    ; out: void
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

    ; in: fp_val
    ; out: void
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
    ; in: row_ptr, row_dim
    ; out: none
    fn_print_row:
        prologue
        save r12, r13, r14
        sub rsp, 8

        mov r12, rdi        ; r12 = row_ptr
        mov r13, rsi        ; r13 = row_dim
        mov r14, 0          ; r14 = elem_index

    .loop:
        mov rdi, fmt_element
        lea rsi, [r12 + r14 * 8]    ; rsi = elem_ptr
        movsd xmm0, [rsi]           ; xmm0 = row_ptr[elem_index]
        mov eax, 1                  ; no vector registers
        call printf wrt ..plt       ; print elem_val
        add r14, 1                  ; increase elem_index
        cmp r13, r14                ; if row_dim > elem_index
        jg .loop                    ; then goto .loop

    .exit:
        xor eax, eax
        add rsp, 8
        restore r14, r13, r12
        epilogue
        ret

    section .text
    ; in: mat_struct_ptr
    ; out: none
    fn_print_matrix:
        prologue
        save r12, r13, r14, r15

        mov r12, [rdi + mat_ptr]    ; r12 = mat_ptr
        mov r13, [rdi + mat_dim]    ; r13 = mat_dim = row_dim
        lea r15, [r13 * 8]          ; r15 = row_size (in bytes)
        mov r14, 0                  ; r14 = row_index
        mov rdi, r13                ; rdi = row_dim
        call fn_print_newline       ; print newline

    .loop:
        mov rdi, r15                ; rdi = row_size (in bytes)
        imul rdi, r14               ; rdi = row_size * row_index
        add rdi, r12                ; rdi = row_ptr = mat_ptr + (row_index * row_size)
        mov rsi, r13                ; rsi = row_dim
        call fn_print_row           ; print row
        add r14, 1                  ; increase row_index
        call fn_print_newline       ; print newline
        cmp r13, r14                ; if row_dim > row_index
        jg .loop                    ; then goto .loop

    .exit:
        xor eax, eax
        restore r15, r14, r13, r12
        epilogue
        ret
%endif
