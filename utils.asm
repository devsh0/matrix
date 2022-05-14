section .text

; in: mat1_struct_ptr, mat2_struct_ptr
; out: int (0 indicates matrices DO NOT have same dim)
fn_check_mat_dim:
    mov r8d, dword [rdi + mat_dim]
    mov r9d, dword [rsi + mat_dim]
    xor eax, eax
    xor r8d, r9d
    jnz .exit
    mov eax, 1

.exit:
    ret

