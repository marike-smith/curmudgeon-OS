bits 16     ;16-bit mode
org 0x7c00  ;bios loads the bootloader at 0x7c00

start:
    ; Store boot drive
    mov [boot_drive], dl

    jmp 0x0000:main

main:       ;set up the stack and data segment registers
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov si, msg_booting
    call print_string

    ; Load kernel from disk
    mov si, msg_loading_kernel
    call print_string

    ; Reset disk system
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; Load kernel sectors
    mov ah, 0x02        ; BIOS read sector function
    mov al, 32          ; Number of sectors to read (increased to 32 sectors = 16KB)
    mov ch, 0           ; Cylinder number
    mov cl, 2           ; Sector number (1-based, sector after bootloader)
    mov dh, 0           ; Head number
    mov dl, [boot_drive] ; Drive number (from BIOS)
    mov bx, 0           ; ES:BX = 0x0000:0x0000
    mov es, bx
    mov bx, 0x1000      ; Load address = 0x0000:0x1000 = physical 0x1000
    int 0x13            ; BIOS interrupt for disk operations
    jc disk_error       ; Jump if carry flag is set (error)

    ; Success message
    mov si, msg_kernel_loaded
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

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $                   ; Infinite loop

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

    ; Print debug color to indicate we're in protected mode (bright red)
    mov dword [0xB8000], 0x4F524F50  ; "PR" in bright white on red background

    ; Jump to kernel's _start entry point (absolute address)
    jmp 0x1000  ; Jump directly to 0x1000 without segment selector

; Variables
boot_drive: db 0
msg_booting: db 'Booting...', 0
msg_loading_kernel: db 'Loading kernel...', 0
msg_kernel_loaded: db 'Kernel loaded!', 0
msg_disk_error: db 'Disk read error!', 0

times 510 - ($ - $$) db 0	;fill the rest of sector with 0
dw 0xAA55			;add boot signature at the end of bootloader    