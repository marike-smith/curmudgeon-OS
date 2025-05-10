# Cross-compiler settings
AS = nasm
CC = i686-elf-gcc
LD = i686-elf-ld

# Flags
ASFLAGS = -f elf32
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -T linker.ld -ffreestanding -O2 -nostdlib

# Directories
SRC_DIR = src
BUILD_DIR = build
BOOTLOADER_DIR = $(SRC_DIR)/bootloader
KERNEL_DIR = $(SRC_DIR)/kernel

# Files
BOOTLOADER = $(BUILD_DIR)/boot.bin
KERNEL = $(BUILD_DIR)/kernel.bin
OS_IMAGE = $(BUILD_DIR)/os.img

# Create build directory
$(shell mkdir -p $(BUILD_DIR))

# Default target
all: $(OS_IMAGE)

# Build bootloader
$(BOOTLOADER): $(BOOTLOADER_DIR)/boot.asm
	$(AS) -f bin $< -o $@

# Build kernel
$(KERNEL): $(KERNEL_DIR)/kernel.asm $(KERNEL_DIR)/kernel.c
	$(AS) $(ASFLAGS) $(KERNEL_DIR)/kernel.asm -o $(BUILD_DIR)/kernel_asm.o
	$(CC) $(CFLAGS) -c $(KERNEL_DIR)/kernel.c -o $(BUILD_DIR)/kernel_c.o
	$(CC) $(LDFLAGS) $(BUILD_DIR)/kernel_asm.o $(BUILD_DIR)/kernel_c.o -o $@ -lgcc

# Create OS image
$(OS_IMAGE): $(BOOTLOADER) $(KERNEL)
	# Create a disk image big enough for bootloader and kernel (2880 * 512 = 1.44MB floppy)
	dd if=/dev/zero of=$@ bs=512 count=2880
	# Copy the bootloader to the first sector
	dd if=$(BOOTLOADER) of=$@ conv=notrunc
	# Copy the kernel starting from the second sector
	dd if=$(KERNEL) of=$@ bs=512 seek=1 conv=notrunc

# Run the OS in QEMU
run: $(OS_IMAGE)
	qemu-system-i386 -fda $(OS_IMAGE) -boot a

# Run with debug options
debug: $(OS_IMAGE)
	qemu-system-i386 -fda $(OS_IMAGE) -boot a -monitor stdio -d int,cpu_reset

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean run debug 