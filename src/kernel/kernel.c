#include <stdint.h>

// VGA text mode constants
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_BUFFER 0xB8000

// VGA colors
#define VGA_COLOR_BLACK 0
#define VGA_COLOR_WHITE 15

// Simple VGA text mode printing
static uint16_t* vga_buffer = (uint16_t*)VGA_BUFFER;
static uint8_t vga_color = VGA_COLOR_BLACK << 4 | VGA_COLOR_WHITE;
static uint32_t vga_column = 0;
static uint32_t vga_row = 0;

// Clear the screen (fill with spaces using current color)
void vga_clear(void) {
    uint16_t entry = (uint16_t)' ' | (uint16_t)vga_color << 8;
    for(uint32_t y = 0; y < VGA_HEIGHT; y++) {
        for(uint32_t x = 0; x < VGA_WIDTH; x++) {
            vga_buffer[y * VGA_WIDTH + x] = entry;
        }
    }
    vga_column = 0;
    vga_row = 0;
}

void vga_putchar(char c) {
    if (c == '\n') {
        vga_column = 0;
        vga_row++;
        if (vga_row >= VGA_HEIGHT) {
            vga_row = 0;
        }
        return;
    }
    
    uint16_t entry = (uint16_t)c | (uint16_t)vga_color << 8;
    vga_buffer[vga_row * VGA_WIDTH + vga_column] = entry;
    
    vga_column++;
    if (vga_column >= VGA_WIDTH) {
        vga_column = 0;
        vga_row++;
        if (vga_row >= VGA_HEIGHT) {
            vga_row = 0;
        }
    }
}

void vga_print(const char* str) {
    for (int i = 0; str[i] != '\0'; i++) {
        vga_putchar(str[i]);
    }
}

// Kernel modules
void init_memory(void);
void init_interrupts(void);
void init_drivers(void);

void kernel_main(void) {
    // First, show visual marker at top of screen (will appear even if printing fails)
    // Make the top-left corner pixels bright green (as a visual indicator)
    for (int i = 0; i < 10; i++) {
        // Bright green (color code 10) on black background
        vga_buffer[i] = 0x0A00 | '*';  // Green asterisks
    }
    
    // Clear the rest of the screen
    vga_clear();
    
    // Print loading message
    vga_print("Loading kernel for testing...\n");
    vga_print("Kernel started successfully!\n");
    
    // Initialize core subsystems
    init_memory();
    init_interrupts();
    init_drivers();

    // Main kernel loop
    while(1) {
        // Kernel main loop
    }
}

// Memory management initialization
void init_memory(void) {
    // TODO: Initialize memory management
}

// Interrupt handling initialization
void init_interrupts(void) {
    // TODO: Set up IDT and enable interrupts
}

// Device driver initialization
void init_drivers(void) {
    // TODO: Initialize device drivers
} 