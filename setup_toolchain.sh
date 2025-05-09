#!/bin/bash

# Install required packages
brew install nasm
brew install i686-elf-gcc
brew install qemu

# Create build directory
mkdir -p build

echo "Toolchain setup complete!"
echo "You can now build your OS using 'make'" 