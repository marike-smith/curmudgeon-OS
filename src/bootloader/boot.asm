bits 16     ;16-bit mode
org 0x7c00  ;bios loads the bootloader at 0x7c00

start:
    jmp 0x0000:main

main:       ;set up the stack
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov si, msg
    call print_string

msg: db 'Hello, World!', 0

times 510 - ($ - $$) db 0	;fill the rest of sector with 0
dw 0xAA55			;add boot signature at the end of bootloader    