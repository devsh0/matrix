section .data
    fmt_err_dim_ne: db 10, "Operand dimensions don't match!", 10, 0

section .text
; in: mat1_struct_ptr, mat1_struct_ptr
; out: res_ptr
; description: adds two matrices and stores the result in the second matrix
fn_add_matrix:
    prologue
    pushmany r12, r13

    mov r12, rdi            ; r12 = mat1_struct_ptr
    mov r13, rsi            ; r13 = mat1_struct_ptr

    call fn_check_mat_dim
    test eax, eax
    jnz .add
    xor eax, eax
    mov rdi, fmt_err_dim_ne
    call printf wrt ..plt

.add:
    mov rdi, [r12 + mat_dim]
    imul rdi, rdi
    mov rax, [r12 + mat_ptr]        ; rax = mat1_ptr
    mov rcx, [r13 + mat_ptr]        ; rcx = mat2_ptr

.loop:
    movsd xmm0, [rax + rdi * 8 - 8]
    addsd xmm0, [rcx + rdi * 8 - 8]
    movsd [rcx + rdi * 8 - 8], xmm0
    sub rdi, 1
    test rdi, rdi
    jnz .loop
    mov rax, r13

.exit:
    popmany r13, r12
    epilogue
    ret
