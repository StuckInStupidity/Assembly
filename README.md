# Assembly

---

| Assembler | Assembly syntax | File extension | Architecture | Usage |
|-----------|-----------------|----------------|--------------|-------|
| GNU Assembler (GAS) | AT&T (default on x86), supports Intel syntax | .s | ARM, AArch64, x86_64-32, etc... | Linux programming, embedded systems, operating systems |
| NASM (Netwide Assembler) / MASM / FASM | Intel | .asm | x86 (32-bits), x86-64 | Windows programming, bootloaders, kernels, desktop software |

## System calls tables

https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/

## Assembly Execution
```
Assembly code (in .s or .asm)
            |
            |
         Assembler
            |
            |
Machine code for the target CPU architecture
```

## With GAS
```
as hello.s -o hello.o
ld hello.o -o hello
```
## With NASM
```
nasm -f elf64 hello.asm -o hello.o
ld hello.o -o hello
```

---

## GNU compiler collection (GCC) pipeline

when running ```gcc hello.c -o hello``` (full pipeline source-to-binary), it does:
```
hello.c  <--preprocessor-->  hello.i  <--compiler-->  hello.s  <--assembler-->  hello.o  <--linker-->  hello(.ex)
```
or
```
gcc -E hello.c -o hello.i    # Expands #include, #define, and other preprocessor directives
gcc -S hello.i -o hello.s    # Translates C into assembly and performs optimizations
gcc -c hello.s -o hello.o    # Converts assembly into machine code stored in an object file
gcc hello.o -o hello         # Combines object files and libraries into an executable
```

## Clang pipeline

when running ```clang hello.c -o hello```
```
hello.c  <--preprocessor-->  hello.i  <--clang generator-->  hello.ll  <--LLVM optimizer-->  hello.ll  <--LLVM generator-->  hello.s  <--assembler-->  hello.o  <--linker-->  hello(.ex)
```
or
```
clang -E hello.c -o hello.i              # Preprocess
clang -S -emit-llvm hello.i -o hello.ll  # Generate LLVM IR
clang -S hello.ll -o hello.s             # LLVM IR → Assembly
clang -c hello.s -o hello.o              # Assemble
clang hello.o -o hello                   # Link
```
Note : LLVM is a reusable compiler framework that takes optimized intermediate code (LLVM IR) and turns it into efficient machine code for different CPU architectures.
