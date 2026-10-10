section .text
global _start

_start:
    mov rax, 41         
    mov rdi, 17         
    mov rsi, 3          
    mov rdx, 0x0300     
    syscall
    
    test rax, rax
    js exit_error
    mov r12, rax        

    sub rsp, 2048       
    mov rsi, rsp        

capture_loop:
    mov rax, 45         
    mov rdi, r12        
    mov rdx, 2048       
    xor r10, r10        
    xor r8, r8          
    xor r9, r9          
    syscall

    test rax, rax
    jle capture_loop     

    mov r13, rax        

    push r13
    mov rax, 1
    mov rdi, 1          
    mov rsi, rsp
    mov rdx, 8
    syscall
    pop r13

    mov rax, 1
    mov rdi, 1          
    mov rsi, rsp        
    mov rdx, r13        
    syscall

    jmp capture_loop

exit_error:
    mov rax, 60         
    mov rdi, 1          
    syscall
