#include <stdint.h>

// Define size_t since we don't have the standard library
typedef unsigned int size_t;

// VGA text mode constants
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_BUFFER 0xB8000

// VGA colors
#define VGA_COLOR_BLACK         0
#define VGA_COLOR_BLUE          1
#define VGA_COLOR_GREEN         2
#define VGA_COLOR_CYAN          3
#define VGA_COLOR_RED           4
#define VGA_COLOR_MAGENTA       5
#define VGA_COLOR_BROWN         6
#define VGA_COLOR_LIGHT_GREY    7
#define VGA_COLOR_DARK_GREY     8
#define VGA_COLOR_LIGHT_BLUE    9
#define VGA_COLOR_LIGHT_GREEN   10
#define VGA_COLOR_LIGHT_CYAN    11
#define VGA_COLOR_LIGHT_RED     12
#define VGA_COLOR_LIGHT_MAGENTA 13
#define VGA_COLOR_LIGHT_BROWN   14
#define VGA_COLOR_WHITE         15

// DEBUG: Direct access to VGA buffer to verify functionality
volatile uint16_t* const VGA_MEM = (uint16_t*)VGA_BUFFER;

// DEBUG: Simple function to write text at specific coordinates
void debug_write_at(int x, int y, const char* str, uint8_t fg, uint8_t bg) {
    uint8_t attribute = (bg << 4) | (fg & 0x0F);
    size_t index = y * VGA_WIDTH + x;
    
    for (size_t i = 0; str[i] != '\0'; i++) {
        VGA_MEM[index + i] = (uint16_t)str[i] | ((uint16_t)attribute << 8);
    }
}

// Function to calculate string length
size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

// Function to write text centered on a specific row
void write_centered(int y, const char* str, uint8_t fg, uint8_t bg) {
    size_t len = strlen(str);
    int x = (VGA_WIDTH - len) / 2; // Calculate center position
    if (x < 0) x = 0; // Safety check
    
    debug_write_at(x, y, str, fg, bg);
}

// Kernel modules
void init_memory(void);
void init_interrupts(void);
void init_drivers(void);

// Kernel entry point
void kernel_main(void) {
    // Clear screen (black background)
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        VGA_MEM[i] = (uint16_t)' ' | ((uint16_t)(VGA_COLOR_BLACK << 4) << 8);
    }
    
    int center_y = VGA_HEIGHT / 2;
    char mem_buf[32] = "CURMUDGEON OS v0.1";
    
    // Center the memory message vertically and horizontally
    write_centered(center_y, mem_buf, VGA_COLOR_LIGHT_RED, VGA_COLOR_BLACK);
    
    
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