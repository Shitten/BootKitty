# === Paths ===
BUILD_DIR = build
BOOT_BIN = $(BUILD_DIR)/boot.bin
STAGE2_BIN = $(BUILD_DIR)/stage2.bin
IMG = $(BUILD_DIR)/bootloader.img

# === Build rules ===
all: $(IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble bootloader (Stage 1)
$(BOOT_BIN): src/boot.asm | $(BUILD_DIR)
	nasm -f bin $< -o $@

# Assemble Stage 2
$(STAGE2_BIN): src/stage2.asm | $(BUILD_DIR)
	nasm -f bin $< -o $@

# Create final disk image
$(IMG): $(BOOT_BIN) $(STAGE2_BIN)
	@echo "🧱 Creating blank disk image..."
	dd if=/dev/zero of=$(IMG) bs=512 count=10 status=none

	@echo "📀 Writing boot sector..."
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc status=none

	@echo "⚙️  Appending stage2..."
	dd if=$(STAGE2_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc status=none

	@echo "✅ Image built successfully: $(IMG)"

# === Run in QEMU ===
run: $(IMG)
	qemu-system-x86_64 -drive format=raw,file=$(IMG)

# Debug mode (logs interrupts, CPU resets, etc.)
debug: $(IMG)
	qemu-system-x86_64 -drive format=raw,file=$(IMG) -d int,cpu_reset -no-reboot -no-shutdown

# === Clean ===
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run debug clean
