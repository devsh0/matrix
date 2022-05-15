section .data
    fmt_err_dim_ne: db 10, "Operand dimensions don't match!", 10, 0

section .text
; in: mat1_struct_ptr, mat2_struct_ptr
; out: res_ptr (mat2_struct_ptr)
; description: adds two matrices and stores the result in the second matrix
fn_add_matrix:
    prologue
    pushmany r12, r13

    mov r12, rdi            ; r12 = mat1_struct_ptr
    mov r13, rsi            ; r13 = mat2_struct_ptr

    call fn_check_mat_dim
    test eax, eax
    jnz .add
    mov rdi, fmt_err_dim_ne
    call printf wrt ..plt
    xor eax, eax
    jmp .exit

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

; in: mat_struct_ptr (rdi), scale_factor (xmm0)
; out: res_ptr (mat_struct_ptr)
fn_scale_matrix:
    mov r8, rdi                     ; r8 = 0x405b10
    mov rsi, [rdi + mat_dim]        ; rsi = mat_dim
    imul rsi, rsi                   ; rsi = elem_index + 1
    mov rdi, [rdi + mat_ptr]        ; rdi = mat_ptr

.loop:
    movsd xmm1, [rdi + (rsi * 8) - 8]
    mulsd xmm1, xmm0
    movsd [rdi + (rsi * 8) - 8], xmm1
    sub rsi, 1
    test rsi, rsi
    jnz .loop

.exit:
    mov rax, r8
    ret

; in: mat1_struct_ptr, mat2_struct_ptr
; out: res_ptr (mat2_struct_ptr)
; description: subtracts mat2 from mat1 and stores result in mat2
fn_subtract_matrix:
    sub rsp, 8
    mov [rsp], rdi

    mov rdi, rsi                ; rdi = mat2_struct_ptr
    mov r8, -1
    cvtsi2sd xmm0, r8           ; xmm0 = -1
    call fn_scale_matrix        ; mat2 is now scaled by -1

    mov rdi, [rsp]
    mov rsi, rax
    call fn_add_matrix

    add rsp, 8
    ret

; in: mat1_struct_ptr, mat2_struct_ptr
; out: res_ptr
; description: computes mat1 dot mat2 and stores the result in a new matrix (not in-place)
fn_dotprod_matrix:
    pushmany r12, r13, r14, r15
    sub rsp, 8

    mov r12, [rdi + mat_dim]    ; r12 = mat1_dim = mat2_dim
    mov r13, [rdi + mat_ptr]    ; rdi = mat1_ptr
    mov r14, [rsi + mat_ptr]    ; rsi = mat2_ptr

    mov rdi, r12
    call fn_alloc_matrix        ; allocate res_mat
    mov r11, rax                ; r11 = res_struct_ptr
    mov r15, [rax]              ; r15 = res_mat_ptr

    xor r8, r8                  ; r8 = row_iter
    xor r10, r10                ; r10 = col_iter
    mov rdi, r13                ; rdi = mat1_ptr
    mov rsi, r14                ; rsi = mat2_ptr
    pxor xmm2, xmm2             ; xmm2 = res[i, j]
    mov rax, 0                  ; rax = i
    mov rcx, r12                ; rcx = mat2_dim
    shl rcx, 3                  ; rcx = stride

.loop:
    mov r9, rcx
    imul r9, rax
    movsd xmm0, [rdi + rax * 8]
    movsd xmm1, [rsi + r9]         ; xmm1 = mat2[RjCi]
    mulsd xmm0, xmm1               ; xmm0 = mat1[RiCj] * mat2[RjCi]
    addsd xmm2, xmm0
    add rax, 1
    cmp rax, r12
    je .next_col
    jmp .loop

.next_col:
    movsd [r15 + r10 * 8], xmm2
    xor rax, rax
    pxor xmm2, xmm2
    add r10, 1
    cmp r10, r12
    je .next_row
    lea rsi, [rsi + r10 * 8]
    jmp .loop

.next_row:
    lea rdi, [rdi + rcx]
    mov rsi, r14
    xor r10, r10
    add r8, 1
    add r15, rcx
    cmp r8, r12
    jne .loop
    mov rax, r11

.exit:
    add rsp, 8
    popmany r15, r14, r13, r12
    ret
