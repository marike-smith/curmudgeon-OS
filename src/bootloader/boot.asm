bits 16     ;16-bit mode
org 0x7c00  ;bios loads the bootloader at 0x7c00

start:
    jmp 0x0000:main    ; Far jump to clear CS:IP

main:
    cli               ; Disable interrupts during setup
    
    ; Set up segment registers
    xor ax, ax        ; Clear AX register (more explicit than mov ax, 0)
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    sti               ; Re-enable interrupts

    mov si, msg
    call print_string
    
    jmp $            ; Infinite loop after printing

print_string:
    push ax          ; Preserve registers
    
.loop:
    lodsb
    or al, al        ; Check if we reached end of string (0)
    jz .done
    mov ah, 0x0e     ; BIOS teletype output
    int 0x10         ; Video interrupt
    jmp .loop

.done:
    pop ax           ; Restore registers
    ret

msg: db 'Hello, World!', 0

times 510 - ($ - $$) db 0    ; Fill the rest of sector with 0
dw 0xAA55                    ; Boot signature    