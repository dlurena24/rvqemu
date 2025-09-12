target remote :1234

break _start
break main
break tea_encrypt_asm
break tea_decrypt_asm

layout asm
layout regs

continue

step
step

info registers

continue
