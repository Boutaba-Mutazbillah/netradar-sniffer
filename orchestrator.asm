section .data
    fifo_path db '/tmp/r_stream', 0
    snif_path db './sniffer', 0
    anal_path db './analyst', 0

section .text
global _start

_start:
    mov rax, 87
    mov rdi, fifo_path
    syscall
    mov rax, 133
    mov rdi, fifo_path
    mov rsi, 0x11B6
    xor rdx, rdx
    syscall
    mov rax, 57
    syscall
    test rax, rax
    js exit_error
    jz run_sniffer      
    mov rax, 59
    mov rdi, anal_path
    xor rsi, rsi
    xor rdx, rdx
    syscall
    jmp exit_error

run_sniffer:
    mov rax, 59
    mov rdi, snif_path
    xor rsi, rsi
    xor rdx, rdx
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
