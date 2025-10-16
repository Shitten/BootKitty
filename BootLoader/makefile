# Compiler and tools
NASM = nasm
QEMU = qemu-system-x86_64

# Directories
SRC_DIR = src
BUILD_DIR = build

# Source files
BOOT_SRC = $(SRC_DIR)/boot.asm
BOOT_BIN = $(BUILD_DIR)/boot.bin

# Default target
all: $(BOOT_BIN)

# Build bootloader
$(BOOT_BIN): $(BOOT_SRC)
	@mkdir -p $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

# Run in QEMU
run: $(BOOT_BIN)
	$(QEMU) -drive format=raw,file=$(BOOT_BIN)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Phony targets
.PHONY: all run clean