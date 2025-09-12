# tea_test.gdb
# Script de depuración para el proyecto TEA.
# Conectar al QEMU en el puerto 1234
target remote :1234

# Breakpoints de interés
break _start
break main
break tea_encrypt_asm
break tea_decrypt_asm

# Cuando lleguemos a _start, mostrar ubicación y continuar
commands 1
  printf "== breakpoint _start hit ==\n"
  info registers
  x/8i $pc
  continue
end

# Cuando lleguemos a main, mostrar la línea y seguir
commands 2
  printf "== breakpoint main hit ==\n"
  # Muestra la fuente alrededor de main (5 lines)
  info line
  list
  continue
end

# Comportamiento automático al entrar a tea_encrypt_asm
commands 3
  printf "== ENTER tea_encrypt_asm ==\n"
  info registers
  printf "a0 (v ptr) = 0x%08x, a1 (key ptr) = 0x%08x\n", $a0, $a1
  x/8x $a0         # ver 8 words en memoria desde v pointer (cuidado, muestra la memoria)
  x/4x $a1         # ver 4 words (clave) desde key pointer
  # Mostrar ensamblador alrededor del PC
  x/16i $pc
  printf "Pausing at start of tea_encrypt_asm. Use 'stepi' / 'finish' / 'info registers' as needed.\n"
  # Do not auto-continue so user can inspect; remove the next 'continue' line if you prefer auto-run
  # continue
end

# Comportamiento automático al entrar a tea_decrypt_asm
commands 4
  printf "== ENTER tea_decrypt_asm ==\n"
  info registers
  printf "a0 (v ptr) = 0x%08x, a1 (key ptr) = 0x%08x\n", $a0, $a1
  x/8x $a0
  x/4x $a1
  x/16i $pc
  printf "Pausing at start of tea_decrypt_asm. Inspect with 'stepi' / 'finish' / 'info registers'.\n"
  # continue
end

# Al terminar (si se llegara a monitor quit)
# (No cerramos QEMU automáticamente para que puedas seguir depurando)
