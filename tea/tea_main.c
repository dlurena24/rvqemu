#include <stdint.h>

// Funciones ASM (extern)
extern void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
extern void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);

// UART mapeado en memoria para imprimir
void print_char(char c) {
    volatile char *uart = (volatile char*)0x10000000;
    *uart = c;
}

void print_string(const char* str) {
    while (*str) {
        print_char(*str++);
    }
}

void print_hex32(uint32_t num) {
    const char hex_chars[] = "0123456789ABCDEF";
    for (int i = 7; i >= 0; i--) {
        int nibble = (num >> (i * 4)) & 0xF;
        print_char(hex_chars[nibble]);
    }
}

void print_block_hex(uint32_t v[2]) {
    print_hex32(v[0]);
    print_char(' ');
    print_hex32(v[1]);
    print_char('\n');
}

void print_ascii_from_block(uint32_t v[2]) {
    char bytes[8];
    for (int i = 0; i < 4; ++i) {
        bytes[i]   = (char)((v[0] >> (i*8)) & 0xFF);
        bytes[4+i] = (char)((v[1] >> (i*8)) & 0xFF);
    }
    for (int i = 0; i < 8; ++i) {
        char c = bytes[i];
        if (c >= 32 && c <= 126) print_char(c);
        else print_char('.');
    }
    print_char('\n');
}

// Conversiones de bytes <-> palabras
void load_block_from_bytes(const uint8_t *b, uint32_t v[2]) {
    uint32_t w0 = 0, w1 = 0;
    for (int i = 0; i < 4; ++i) w0 |= ((uint32_t)b[i]) << (i*8);
    for (int i = 0; i < 4; ++i) w1 |= ((uint32_t)b[4+i]) << (i*8);
    v[0] = w0; v[1] = w1;
}

void store_block_to_bytes(const uint32_t v[2], uint8_t *b) {
    for (int i = 0; i < 4; ++i) b[i]   = (v[0] >> (i*8)) & 0xFF;
    for (int i = 0; i < 4; ++i) b[4+i] = (v[1] >> (i*8)) & 0xFF;
}

// Cifra un mensaje de longitud arbitraria
void encrypt_message(const uint8_t *msg, int len, uint32_t key[4], uint8_t *cipher) {
    int num_blocks = (len + 7) / 8;  // redondeo arriba
    uint8_t block[8];
    uint32_t v[2];

    for (int b = 0; b < num_blocks; b++) {
        for (int i = 0; i < 8; i++) {
            int idx = b*8 + i;
            if (idx < len) block[i] = msg[idx];
            else block[i] = 0; // padding
        }

        load_block_from_bytes(block, v);
        tea_encrypt_asm(v, key);
        store_block_to_bytes(v, &cipher[b*8]);

        print_block_hex(v);
    }
}

// Descifra un mensaje de longitud arbitraria
void decrypt_message(const uint8_t *cipher, int len, uint32_t key[4]) {
    int num_blocks = (len + 7) / 8;
    uint8_t block[8];
    uint32_t v[2];

    for (int b = 0; b < num_blocks; b++) {
        for (int i = 0; i < 8; i++) {
            int idx = b*8 + i;
            block[i] = cipher[idx];
        }

        load_block_from_bytes(block, v);
        tea_decrypt_asm(v, key);

        print_ascii_from_block(v);
    }
}

void main() {
    uint32_t key[4] = {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210};

    // Caso 1: mensaje exacto 8 bytes
    const char *msg1 = "HOLA1234";
    int len1 = 8;
    uint8_t cipher1[16]; // espacio suficiente
    print_string("Caso 1: HOLA1234\n");
    print_string("Original: "); print_string(msg1); print_char('\n');
    print_string("Cifrado (hex):\n");
    encrypt_message((const uint8_t*)msg1, len1, key, cipher1);
    print_string("Descifrado (ascii):\n");
    decrypt_message(cipher1, len1, key);

    // Caso 2: mensaje mas largo
    const char *msg2 = "Mensaje de prueba para TEA";
    int len2 = 27;
    uint8_t cipher2[40]; // redondeado
    print_string("\nCaso 2: Mensaje largo\n");
    print_string("Original: "); print_string(msg2); print_char('\n');
    print_string("Cifrado (hex):\n");
    encrypt_message((const uint8_t*)msg2, len2, key, cipher2);
    print_string("Descifrado (ascii):\n");
    decrypt_message(cipher2, len2, key);

    while (1) {
        __asm__ volatile ("nop");
    }
}
