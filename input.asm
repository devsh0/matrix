section .data
    scanf_int_fmt: db "%d", 0
    scanf_double_fmt: db "%lf", 0

section .data
    dim_prompt: db "Matrix dimension: ", 0
    fmt_err_dim: db "Dimension must be between %d-%d inclusive!", 10, 0

section .text
; in: void
; out: mat_dim
fn_input_dim:
    sub rsp, 8

    ; input mat_dim
    mov rdi, dim_prompt
    xor eax, eax
    call printf wrt ..plt
    mov rdi, scanf_int_fmt
    lea rsi, [rsp + 4]
    call scanf wrt ..plt

    mov eax, dword [rsp + 4]            ; eax = mat_dim
    cmp eax, min_dim                    ; check mat_dim < min_dim
    jl .error                           ; if true, goto .error
    cmp eax, max_dim                    ; check mat_dim <= max_dim
    jle .exit                           ; if true, goto .exit

.error:
    mov rdi, fmt_err_dim
    mov rsi, min_dim
    mov rdx, max_dim
    xor eax, eax
    call printf wrt ..plt
    mov rax, -1

.exit:
    add rsp, 8
    ret

section .data
    row_prompt: db "Elements of row #%d: ", 0

section .text
; in: row_ptr, row_dim, row_index
; out: void
fn_input_row:
    prologue
    pushmany r12, r13, r14
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
    cmp r13, r14                ; if row_dim > elem_index
    jg .loop                    ; then goto .loop

.exit:
    add rsp, 8
    popmany r14, r13, r12
    epilogue
    ret

; in: void
; out: mat_struct_ptr
fn_input_matrix:
    prologue
    pushmany rbx, r13, r14, r15

    call fn_input_dim           ; input mat_dim
    cmp eax, -1
    jne .allocate
    xor eax, eax
    jmp .exit

.allocate:
    movsx rdi, eax
    call fn_alloc_matrix
    mov rbx, rax                ; rbx = mat_struct_ptr

    mov r13, [rbx + mat_ptr]    ; r13 = mat_ptr
    mov r14, [rbx + mat_dim]    ; r14 = row_dim = mat_dim
    shl r14, 3                  ; r14 = row_size (in bytes)
    mov r15, 0                  ; r15 = row_index

.loop:
    mov rax, r15                ; rax = row_index
    imul rax, r14               ; rax = row_index * row_size
    lea rdi, [r13 + rax]        ; rdi = row_ptr = mat_ptr + (row_index * row_size)
    mov rsi, [rbx + mat_dim]    ; rsi = row_dim = mat_dim
    mov rdx, r15                ; rdx = row_index
    call fn_input_row           ; input an entire row
    add r15, 1                  ; increase row_index
    cmp [rbx + mat_dim], r15    ; if mat_dim > row_index
    jg .loop                    ; then goto .loop
    mov rax, rbx

.exit:
    popmany r15, r14, r13, rbx
    epilogue
    ret
