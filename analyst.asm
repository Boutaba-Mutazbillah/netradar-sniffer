section .data
    h_GetStdHandle db 'GetStdHandle', 0
    h_ReadFile     db 'ReadFile', 0
    h_ExitProcess  db 'ExitProcess', 0

section .text
global _start

_start:
    xor edx, edx
    mov edx, [fs:edx + 0x30]
    mov edx, [edx + 0x0C]
    mov edx, [edx + 0x1C]
init_loop:
    mov eax, [edx + 0x08]
    mov esi, [edx + 0x20]
    mov edx, [edx]
    cmp byte [esi + 12], 0
    jne init_loop
    mov [kernel32_base], eax

    mov ecx, h_GetStdHandle
    call get_proc_address
    mov [p_GetStdHandle], eax

    mov ecx, h_ReadFile
    call get_proc_address
    mov [p_ReadFile], eax

    mov ecx, h_ExitProcess
    call get_proc_address
    mov [p_ExitProcess], eax

    push -10
    call [p_GetStdHandle]
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
    call [p_ReadFile]
    cmp dword [bytes_read], 8
    jne exit_clean
    mov ecx, [esp]
    sub esp, ecx
    push 0
    push bytes_read
    push ecx
    push esp
    push dword [stdin_handle]
    call [p_ReadFile]
    cmp word [esp + 12], 0x0008
    jne next_iteration

next_iteration:
    add esp, ecx
    jmp read_loop

exit_clean:
    add esp, 16
    push 0
    call [p_ExitProcess]

get_proc_address:
    mov ebp, [kernel32_base]
    mov eax, [ebp + 0x3C]
    mov edx, [ebp + eax + 0x78]
    add edx, ebp
    mov ecx, [edx + 0x18]
    mov ebx, [edx + 0x20]
    add ebx, ebp
find_func_loop:
    dec ecx
    js func_not_found
    mov esi, [ebx + ecx * 4]
    add esi, ebp
    mov edi, ecx
compare_name:
    cmpsb
    jne find_func_loop
    cmp byte [esi-1], 0
    jne compare_name
    mov ebx, [edx + 0x24]
    add ebx, ebp
    mov cx, [ebx + ecx * 2]
    mov ebx, [edx + 0x1C]
    add ebx, ebp
    mov eax, [ebx + ecx * 4]
    add eax, ebp
    ret
func_not_found:
    xor eax, eax
    ret

section .bss
    kernel32_base resd 1
    p_GetStdHandle resd 1
    p_ReadFile     resd 1
    p_ExitProcess  resd 1
    stdin_handle  resd 1
    bytes_read    resd 1
