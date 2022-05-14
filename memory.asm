section .text
; in: mat_dim
; out: mat_struct_ptr
fn_alloc_matrix:
    prologue
    pushmany rbx
    sub rsp, 8

    mov rbx, rdi
    mov rdi, Matrix_size        ; rdi = mat_struct_size (in bytes)
    call malloc wrt ..plt       ; allocate mat_struct; rax = mat_struct_ptr
    mov [rax + mat_dim], rbx    ; Matrix.mat_dim = mat_dim
    mov rbx, rax                ; rbx = mat_struct_ptr

    mov rdi, [rbx + mat_dim]    ; r12 = row_dim = mat_dim
    imul rdi, rdi               ; rdi *= rdi = pow(mat_dim, 2)
    shl rdi, 3                  ; rdi *= 8 = mat_size (in bytes)
    call malloc wrt ..plt       ; allocate buffer for matrix, mat_ptr in eax
    mov [rbx + mat_ptr], rax

.exit:
    mov rax, rbx
    add rsp, 8
    popmany rbx
    epilogue
    ret

; in: mat_struct_ptr
; out: void
fn_free_matrix:
    push rbx
    mov rbx, rdi
    mov rdi, [rbx + mat_ptr]    ; rdi = Matrix.mat_ptr
    call free wrt ..plt         ; free Matrix.mat_ptr
    mov rdi, rbx                ; rdi = mat_struct_ptr
    call free wrt ..plt         ; free mat_struct_ptr
    pop rbx
    ret
