section .data
    pipe_path db '\\.\pipe\r_stream', 0
    snif_path db 'sniffer.exe', 0
    anal_path db 'analyst.exe', 0
section .text
global _start
extern _CreateNamedPipeA@32
extern _CreateProcessA@40
extern _ExitProcess@4
_start:
    push 0
    push 0
    push 0
    push 255
    push 2048
    push 2048
    push 3
    push pipe_path
    call _CreateNamedPipeA@32
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
    call _CreateProcessA@40
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
    call _CreateProcessA@40
    test eax, eax
    jz exit_error
    push 0
    call _ExitProcess@4
exit_error:
    push 1
    call _ExitProcess@4
section .bss
    pipe_handle     resd 1
    start_info_snif resb 68
    proc_info_snif  resb 16
    start_info_anal resb 68
    proc_info_anal  resb 16
