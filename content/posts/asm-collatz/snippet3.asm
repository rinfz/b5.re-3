global _start
section .text
_start:
    mov rdi, 156
    call collatz
    mov rdi, rax
    mov rax, 60
    syscall
collatz:
    xor rcx, rcx
.loop:
    cmp rdi, 1
    je .done
    inc rcx
    mov rax, rdi
    and rax, 1    ; ┐
    test rax, rax ; ┴ x % 2 == 0
    jne .odd
    mov rax, rdi
    shr rax, 1    ;   x /= 2
    mov rdi, rax
    jmp .loop
.odd:
    mov rax, rdi  ; ┐
    add rax, rax  ; │
    add rax, rdi  ; │
    add rax, 1    ; ┴ 3*x + 1
    mov rdi, rax
    jmp .loop
.done:
    mov rax, rcx
    ret