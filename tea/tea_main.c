#include <stdint.h>

// Declaraciones de funciones en ASM
extern void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
extern void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);

// Funciones de impresión (simulan UART en QEMU)
void print_char(char c) {
    volatile char *uart = (volatile char*)0x10000000;
    *uart = c;
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_hex(uint32_t num) {
    const char hex_chars[] = "0123456789ABCDEF";
    for (int i = 7; i >= 0; i--) {
        int nibble = (num >> (i * 4)) & 0xF;
        print_char(hex_chars[nibble]);
    }
}

// Programa principal
void main() {
    // Clave de 128 bits (ejemplo)
    uint32_t key[4] = {0x01234567, 0x89ABCDEF, 0xFEDCBA98, 0x76543210};

    // Mensaje de prueba (8 bytes = 64 bits)
    uint32_t v[2] = {0x484F4C41, 0x31323334}; // "HOLA1234" en ASCII

    print_string("Mensaje original:\n");
    print_hex(v[0]); print_char(' '); print_hex(v[1]); print_char('\n');

    // Cifrar
    tea_encrypt_asm(v, key);
    print_string("Cifrado:\n");
    print_hex(v[0]); print_char(' '); print_hex(v[1]); print_char('\n');

    // Descifrar
    tea_decrypt_asm(v, key);
    print_string("Descifrado:\n");
    print_hex(v[0]); print_char(' '); print_hex(v[1]); print_char('\n');

    while (1) {
        __asm__ volatile ("nop");
    }
}
