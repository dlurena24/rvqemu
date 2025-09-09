    .section .text
    .globl tea_encrypt_asm
    .globl tea_decrypt_asm

# void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4])
# a0 = puntero a v
# a1 = puntero a key
tea_encrypt_asm:
    # Prologo
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)

    # Cargar v[0], v[1]
    lw s0, 0(a0)     # v0
    lw s1, 4(a0)     # v1
    li s2, 0         # sum = 0
    li s3, 0x9e3779b9  # delta

    # Cargar clave
    lw s4, 0(a1)     # key[0]
    lw s5, 4(a1)     # key[1]
    lw t0, 8(a1)     # key[2]
    lw t1, 12(a1)    # key[3]

    li t2, 32        # contador de rondas

encrypt_loop:
    add s2, s2, s3       # sum += delta

    # v0 += ((v1<<4)+key[0]) ^ (v1+sum) ^ ((v1>>5)+key[1])
    sll t3, s1, 4
    add t3, t3, s4
    add t4, s1, s2
    xor t3, t3, t4
    srl t4, s1, 5
    add t4, t4, s5
    xor t3, t3, t4
    add s0, s0, t3

    # v1 += ((v0<<4)+key[2]) ^ (v0+sum) ^ ((v0>>5)+key[3])
    sll t3, s0, 4
    add t3, t3, t0
    add t4, s0, s2
    xor t3, t3, t4
    srl t4, s0, 5
    add t4, t4, t1
    xor t3, t3, t4
    add s1, s1, t3

    addi t2, t2, -1
    bnez t2, encrypt_loop

    # Guardar resultados
    sw s0, 0(a0)
    sw s1, 4(a0)

    # Epilogo
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    addi sp, sp, 32
    ret

# void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4])
# a0 = puntero a v
# a1 = puntero a key
tea_decrypt_asm:
    # Prologo
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)

    # Cargar v[0], v[1]
    lw s0, 0(a0)     # v0
    lw s1, 4(a0)     # v1
    li s3, 0x9e3779b9  # delta
    li t2, 32
    mul s2, s3, t2     # sum = delta*32

    # Cargar clave
    lw s4, 0(a1)     # key[0]
    lw s5, 4(a1)     # key[1]
    lw t0, 8(a1)     # key[2]
    lw t1, 12(a1)    # key[3]

decrypt_loop:
    # v1 -= ((v0<<4)+key[2]) ^ (v0+sum) ^ ((v0>>5)+key[3])
    sll t3, s0, 4
    add t3, t3, t0
    add t4, s0, s2
    xor t3, t3, t4
    srl t4, s0, 5
    add t4, t4, t1
    xor t3, t3, t4
    sub s1, s1, t3

    # v0 -= ((v1<<4)+key[0]) ^ (v1+sum) ^ ((v1>>5)+key[1])
    sll t3, s1, 4
    add t3, t3, s4
    add t4, s1, s2
    xor t3, t3, t4
    srl t4, s1, 5
    add t4, t4, s5
    xor t3, t3, t4
    sub s0, s0, t3

    sub s2, s2, s3   # sum -= delta
    addi t2, t2, -1
    bnez t2, decrypt_loop

    # Guardar resultados
    sw s0, 0(a0)
    sw s1, 4(a0)

    # Epilogo
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    addi sp, sp, 32
    ret
