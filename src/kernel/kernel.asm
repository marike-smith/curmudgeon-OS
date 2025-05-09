bits 32

global _start

section .text
_start:
    ; Set up stack
    mov esp, 0x90000

    ; Call C kernel main
    extern kernel_main
    call kernel_main

    ; If kernel_main returns, halt
    cli
    hlt 