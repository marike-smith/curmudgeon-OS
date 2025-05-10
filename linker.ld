ENTRY(_start)

SECTIONS
{
    /* Set the output address to 0x1000 */
    . = 0x1000;

    /* First put the multiboot header, as it must be within the first 8K */
    .text ALIGN(4K) : 
    {
        /* Ensure that _start is at the beginning of the section */
        *(.text.start)
        *(.text._start)
        *(.text)
    }

    /* Read-only data */
    .rodata ALIGN(4K) : 
    {
        *(.rodata)
    }

    /* Read-write data (initialized) */
    .data ALIGN(4K) : 
    {
        *(.data)
    }

    /* Read-write data (uninitialized) and stack */
    .bss ALIGN(4K) : 
    {
        *(COMMON)
        *(.bss)
    }
} 