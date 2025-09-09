#!/bin/bash
# Build script for TEA project
echo "Building TEA project..."

# Compilar C principal
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 -gdwarf-4 \
    -c tea_main.c -o tea_main.o

if [ $? -ne 0 ]; then
    echo "C compilation failed"
    exit 1
fi

# Compilar startup
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 -gdwarf-4 \
    -c startup.s -o startup.o

if [ $? -ne 0 ]; then
    echo "Startup assembly compilation failed"
    exit 1
fi

# Compilar TEA ASM
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 -gdwarf-4 \
    -c tea_asm.s -o tea_asm.o

if [ $? -ne 0 ]; then
    echo "TEA assembly compilation failed"
    exit 1
fi

# Linkear todo
riscv64-unknown-elf-gcc \
    -march=rv32im \
    -mabi=ilp32 \
    -nostdlib \
    -ffreestanding \
    -g3 -gdwarf-4 \
    startup.o tea_main.o tea_asm.o \
    -T linker.ld -o tea.elf

if [ $? -eq 0 ]; then
    echo "Build successful: tea.elf created"
else
    echo "Linking failed"
    exit 1
fi
