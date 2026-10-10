section .data
    pipe_path db '\\.\pipe\r_stream', 0
section .text
global _start
extern _WSAStartup@8
extern _socket@12
extern _CreateFileA@28
extern _recvfrom@24
extern _WriteFile@20
extern _ExitProcess@4
_start:
    sub esp, 400
    push esp
    push 0x0202
    call _WSAStartup@8
    add esp, 400
    push 3
    push 3
    push 2
    call _socket@12
    mov [sock_handle], eax
    cmp eax, -1
    je exit_error
    push 0
    push 80
    push 3
    push 0
    push 1
    push 0xC0000000
    push pipe_path
    call _CreateFileA@28
    mov [pipe_handle], eax
    cmp eax, -1
    je exit_error
    sub esp, 2048
capture_loop:
    push 0
    push 0
    push 0
    push 2048
    push esp
    push dword [sock_handle]
    call _recvfrom@24
    test eax, eax
    jle capture_loop
    mov [pkt_size], eax
    push 0
    push bytes_written
    push 8
    push pkt_size
    push dword [pipe_handle]
    call _WriteFile@20
    push 0
    push bytes_written
    push dword [pkt_size]
    push esp
    push dword [pipe_handle]
    call _WriteFile@20
    jmp capture_loop
exit_error:
    push 1
    call _ExitProcess@4
section .bss
    sock_handle   resd 1
    pipe_handle   resd 1
    pkt_size      resd 1
    bytes_written resd 1
