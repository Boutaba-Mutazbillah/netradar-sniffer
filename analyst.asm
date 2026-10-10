section .text
global _start

_start:
    sub rsp, 16

read_loop:
    xor rax, rax
    xor rdi, rdi          
    mov rsi, rsp        
    mov rdx, 8
    syscall

    cmp rax, 8
    jne exit_clean      

    mov r14, [rsp]      

    sub rsp, r14
    
    xor rax, rax
    xor rdi, rdi
    mov rsi, rsp
    mov rdx, r14
    syscall

    cmp word [rsp + 12], 0x0008 
    jne next_iteration

next_iteration:
    add rsp, r14        
    jmp read_loop

exit_clean:
    add rsp, 16
    mov rax, 60         
    xor rdi, rdi
    syscall
