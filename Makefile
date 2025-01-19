# Makefile for building the bootloader

# Directories
BUILD_DIR = build

# Tools
ASM = nasm
QEMU = qemu-system-x86_64

# Files
BOOTLOADER = src/bootloader/boot.asm
BOOTLOADER_BIN = $(BUILD_DIR)/boot.bin

# Flags
ASM_FLAGS = -f bin

.PHONY: all clean run

all: $(BUILD_DIR) $(BOOTLOADER_BIN)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOTLOADER_BIN): $(BOOTLOADER)
	$(ASM) $(ASM_FLAGS) $(BOOTLOADER) -o $(BOOTLOADER_BIN)

run: all
	$(QEMU) -drive format=raw,file=$(BOOTLOADER_BIN)

clean:
	rm -rf $(BUILD_DIR) 