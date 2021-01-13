; Before
mov rax, rdi
xor rdx, rdx
mov rbx, 2
div rbx

; After
shr rax, 1