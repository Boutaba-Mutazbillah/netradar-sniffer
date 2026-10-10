section .text
global _start
extern _ReadFile@20
extern _ExitProcess@4
extern _GetStdHandle@4
_start:
    push -10
    call _GetStdHandle@4
    mov [stdin_handle], eax
    sub esp, 16
read_loop:
    push 0
    push bytes_read
    push 8
    mov eax, esp
    add eax, 8
    push eax            
    push dword [stdin_handle]
    call _ReadFile@20
    cmp dword [bytes_read], 8
    jne exit_clean
    mov ecx, [esp]
    sub esp, ecx
    push 0
    push bytes_read
    push ecx
    push esp
    push dword [stdin_handle]
    call _ReadFile@20
    cmp word [esp + 12], 0x0008
    jne next_iteration
next_iteration:
    add esp, ecx
    jmp read_loop
exit_clean:
    add esp, 16
    push 0
    call _ExitProcess@4
section .bss
    stdin_handle resd 1
    bytes_read   resd 1
