bits 16     ;16-bit mode
org 0x7c00  ;bios loads the bootloader at 0x7c00

start:
    jmp 0x0000:main

main:       ;set up the stack and data segment registers
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov si, msg
    call print_string

    ; Enable A20 line
    call enable_a20

    ; Load GDT
    cli                     ; Disable interrupts
    lgdt [gdt_descriptor]   ; Load GDT

    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Jump to 32-bit code
    jmp 0x08:protected_mode

enable_a20:
    ; Try BIOS method first
    mov ax, 0x2401
    int 0x15
    ret

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e     ;0x0e is the bios interrupt for teletype output
    int 0x10         ;interrupt to display the character in al
    jmp print_string
.done:
    ret

; GDT
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0

    ; Code segment descriptor
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10011010b    ; Access byte
    db 11001111b    ; Flags and Limit (bits 16-19)
    db 0x00         ; Base (bits 24-31)

    ; Data segment descriptor
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10010010b    ; Access byte
    db 11001111b    ; Flags and Limit (bits 16-19)
    db 0x00         ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                 ; Address of GDT

; 32-bit protected mode code
bits 32
protected_mode:
    ; Set up segment registers
    mov ax, 0x10    ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up stack
    mov esp, 0x90000

    ; Jump to kernel
    jmp 0x08:0x1000  ; Jump to kernel at 0x1000

msg: db 'Booting...', 0

times 510 - ($ - $$) db 0	;fill the rest of sector with 0
dw 0xAA55			;add boot signature at the end of bootloader    