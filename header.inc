%ifndef __HEADERS__
    %define __HEADERS__

    default rel
    extern scanf
    extern printf
    extern malloc
    extern free

    %include "common.asm"
    %include "utils.asm"
    %include "memory.asm"
    %include "input.asm"
    %include "print.asm"
    %include "compute.asm"
%endif
