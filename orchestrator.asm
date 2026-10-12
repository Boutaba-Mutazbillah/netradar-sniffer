section .data
    pipe_path db '\\.\pipe\r_stream', 0
    snif_path db 'sniffer.exe', 0
    anal_path db 'analyst.exe', 0

    h_CreateNamedPipeA db 'CreateNamedPipeA', 0
    h_CreateProcessA    db 'CreateProcessA', 0
    h_ExitProcess       db 'ExitProcess', 0
    h_SetPriorityClass  db 'SetPriorityClass', 0
    h_GetCurrentProcess db 'GetCurrentProcess', 0
    h_GetCurrentThread  db 'GetCurrentThread', 0
    h_SetThreadAffinityMask db 'SetThreadAffinityMask', 0

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

    mov ecx, h_CreateNamedPipeA
    call get_proc_address
    mov [p_CreateNamedPipeA], eax

    mov ecx, h_CreateProcessA
    call get_proc_address
    mov [p_CreateProcessA], eax

    mov ecx, h_ExitProcess
    call get_proc_address
    mov [p_ExitProcess], eax

    mov ecx, h_SetPriorityClass
    call get_proc_address
    mov [p_SetPriorityClass], eax

    mov ecx, h_GetCurrentProcess
    call get_proc_address
    mov [p_GetCurrentProcess], eax

    mov ecx, h_GetCurrentThread
    call get_proc_address
    mov [p_GetCurrentThread], eax

    mov ecx, h_SetThreadAffinityMask
    call get_proc_address
    mov [p_SetThreadAffinityMask], eax

    call [p_GetCurrentProcess]
    push 0x00000100
    push eax
    call [p_SetPriorityClass]

    call [p_GetCurrentThread]
    push 1
    push eax
    call [p_SetThreadAffinityMask]

    push 0
    push 0
    push 0
    push 255
    push 2048
    push 2048
    push 3
    push pipe_path
    call [p_CreateNamedPipeA]
    mov [pipe_handle], eax
    cmp eax, -1
    je exit_error

    push proc_info_snif
    push start_info_snif
    push 0
    push 0
    push 0
    push 0
    push 0
    push 0
    push snif_path
    push 0
    call [p_CreateProcessA]
    test eax, eax
    jz exit_error

    push proc_info_anal
    push start_info_anal
    push 0
    push 0
    push 0
    push 0
    push 0
    push 0
    push anal_path
    push 0
    call [p_CreateProcessA]
    test eax, eax
    jz exit_error

    push 0
    call [p_ExitProcess]

exit_error:
    push 1
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
    kernel32_base   resd 1
    p_CreateNamedPipeA    resd 1
    p_CreateProcessA       resd 1
    p_ExitProcess          resd 1
    p_SetPriorityClass     resd 1
    p_GetCurrentProcess    resd 1
    p_GetCurrentThread     resd 1
    p_SetThreadAffinityMask resd 1
    pipe_handle     resd 1
    start_info_snif resb 68
    proc_info_snif  resb 16
    start_info_anal resb 68
    proc_info_anal  resb 16
