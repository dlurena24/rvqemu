# Proyecto Individual: Implementación de Cifrado TEA usando C y Ensamblador RISC-V en QEMU

El propósito del desarrollo de este proyecto es implementar un algoritmo de cifrado TEA (Tiny Encryption Algorithm) utilizando un entorno RISC-V, mediante la implementación de lógica de alto nivel en lenguaje C, mientras se implementa las funciones de cifrado y descifrado críticas se implementan en ensamblador RISC-V.
Este proyecto fue creado a partir de un fork realizado al repositorio https://gitlab.com/jgonzalez.tec/rvqemu/, tomándose éste como base para el desarrollo del proyecto.
Desarrollado por el estudiante Daniel Ureña López, carné institucional 2020425815, Tecnológico de Costa Rica.

---

## 1. Estructura del proyecto

```
.
├── Dockerfile
├── run.sh
├── tea/ 
│   ├── tea_main.c
│   ├── tea_asm.s
│   ├── linker.ld
│   ├── build.sh
│   └── run-qemu.sh
└── README.md
```

- `tea/` contiene los archivos relacionados al proyecto desarrollado
- `Dockerfile` define la imagen que incluye el emulador QEMU y el toolchain RISC-V
- `run.sh` automatiza la construcción de la imagen y la ejecución del contenedor

---

## 2. Inicio rápido

### Paso 1: Construir el contenedor
```bash
chmod +x run.sh
./run.sh
```

### Paso 2: Compilar el proyecto
```bash
cd /workspace/tea
./build.sh
```

### Paso 3: Ejecutar con QEMU y depurar
```bash
# En una terminal: iniciar QEMU con servidor GDB
./run-qemu.sh

# En otra terminal: conectar GDB
docker exec -it rvqemu_dev /bin/bash
cd /workspace/tea
gdb-multiarch [archivo-elf]
```

---

## 3. Uso detallado

### Construcción del contenedor
El script `run.sh` construye la imagen `rvqemu` y crea un contenedor interactivo que monta el directorio del proyecto en `/workspace`.

### Compilación
Cada ejemplo incluye un script `build.sh` que maneja la compilación automáticamente.

**Opciones de compilación utilizadas**:
- `-march=rv32im`: arquitectura RISC-V 32 bits con extensiones I y M
- `-mabi=ilp32`: ABI ILP32
- `-nostdlib -ffreestanding`: entorno bare-metal
- `-g`: información de depuración para GDB

### Ejecución y depuración
1. **QEMU**: `run-qemu.sh` inicia QEMU con servidor GDB en puerto 1234
2. **GDB**: Conectar desde otra terminal para depuración interactiva

**Comandos útiles de GDB**:
```gdb
target remote :1234    # Conectar al servidor GDB
break _start           # Punto de ruptura al inicio
continue               # Continuar ejecución
layout asm             # Vista de ensamblador
layout regs            # Vista de registros
step                   # Ejecutar siguiente instrucción
info registers         # Mostrar registros
monitor quit           # Finalizar sesión
```

---

## 4. Detalles del proyecto

Para información específica sobre el proyecto, consultar:
- [`tea/README.md`](tea/README.md) - Información general sobre ejecución del proyecto.
