#!/bin/bash
# Run TEA project in QEMU with GDB support
echo "Starting QEMU with GDB server on port 1234..."
echo "In another terminal: gdb-multiarch tea.elf"
echo "Then: target remote :1234"

qemu-system-riscv32 \
    -machine virt \
    -nographic \
    -bios none \
    -kernel tea.elf \
    -S \
    -gdb tcp::1234
