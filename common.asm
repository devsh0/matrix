%ifndef __COMMON__
    %define __COMMON__
    %macro prologue 0
        push rbp
        mov rbp, rsp
    %endmacro

    %macro epilogue 0
        mov rsp, rbp
        pop rbp
    %endmacro

    %macro pushmany 1-*
        %rep %0
            push %1
            %rotate 1
        %endrep
    %endmacro

    %macro popmany 1-*
        %rep %0
            pop %1
            %rotate 1
        %endrep
    %endmacro

section .bss
    min_dim: equ 1
    max_dim: equ 64
    dim_ptr: resd 1

    struc Matrix
        mat_ptr: resq 1
        mat_dim: resd 1
    endstruc
%endif
