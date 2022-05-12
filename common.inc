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

    %macro save 1-*
        %rep %0
            push %1
            %rotate 1
        %endrep
    %endmacro

    %macro restore 1-*
        %rep %0
            pop %1
            %rotate 1
        %endrep
    %endmacro
%endif
