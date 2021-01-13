global _start

section .text
_start:
  mov rdi, 156 ; x
  call collatz

  mov rdi, rax
  mov rax, 60
  syscall

; uint collatz(uint x)
collatz:
  xor rcx, rcx ; result
.loop:
  cmp rdi, 1
  je .done

  inc rcx

  ; x % 2
  mov rax, rdi
  xor rdx, rdx
  mov rbx, 2
  div rbx

  cmp rdx, 0 ; even
  jne .odd
  mov rdi, rax ; x = x / 2
  jmp .loop
.odd:
  mov rax, rdi
  mov r8, 3
  mul r8 ; 3*x
  inc rax ; x + 1
  mov rdi, rax
  jmp .loop

.done:
  mov rax, rcx
  ret