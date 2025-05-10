bits 32

section .text
global _start        ; Make _start visible to the linker
extern kernel_main   ; Declare kernel_main as external

; Entry point - this must be at the very beginning of the binary
_start:
    ; Clear registers for a clean state
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    
    ; Set up stack
    mov esp, 0x90000
    
    ; Call C kernel main
    call kernel_main
    
    ; If kernel_main returns, halt the CPU
    cli              ; Disable interrupts
    hlt              ; Halt the CPU
    jmp $            ; Infinite loop (just in case) 