# Compiling C Code on Linux — Quick Reference

## Basic Compilation

```bash
gcc program.c -o program
```
Compiles `program.c` into an executable named `program`. Run it with `./program`.

If you skip `-o`, gcc produces a default executable called `a.out`:
```bash
gcc program.c
./a.out
```

## Common Flags

| Flag | Purpose |
|---|---|
| `-o <name>` | Set output file name |
| `-Wall` | Enable most warning messages |
| `-Wextra` | Enable extra warnings beyond `-Wall` |
| `-g` | Include debug symbols (for use with `gdb`) |
| `-O0`, `-O1`, `-O2`, `-O3` | Optimization levels (O0 = none, O3 = aggressive) |
| `-std=c11` / `-std=c99` | Specify the C standard to use |
| `-c` | Compile to object file only (no linking) |
| `-I<dir>` | Add a directory to search for header files |
| `-L<dir>` | Add a directory to search for libraries |
| `-l<name>` | Link against a library (e.g. `-lm` for the math library) |

A solid everyday compile command:
```bash
gcc -Wall -Wextra -g -std=c11 program.c -o program
```

## Multi-File Projects

Compile each file to an object file, then link them together:
```bash
gcc -c file1.c -o file1.o
gcc -c file2.c -o file2.o
gcc file1.o file2.o -o program
```

Or do it in one step:
```bash
gcc file1.c file2.c -o program
```

## Linking Libraries

Example linking the math library (needed for functions like `sqrt`, `pow`):
```bash
gcc program.c -o program -lm
```

## Using Make

For larger projects, a `Makefile` automates this:
```makefile
program: file1.o file2.o
	gcc file1.o file2.o -o program

file1.o: file1.c
	gcc -c file1.c

file2.o: file2.c
	gcc -c file2.c

clean:
	rm -f *.o program
```
Then just run:
```bash
make
```

## Debugging

Compile with `-g`, then run with `gdb`:
```bash
gcc -g program.c -o program
gdb ./program
```

## Alternative Compiler

`clang` is a drop-in alternative to `gcc` with mostly the same flags:
```bash
clang program.c -o program
```

## Static and Shared Libraries

**Static library (`.a`):**
```bash
gcc -c file1.c file2.c
ar rcs libmylib.a file1.o file2.o
gcc main.c -L. -lmylib -o program
```

**Shared library (`.so`):**
```bash
gcc -fPIC -c file1.c file2.c
gcc -shared -o libmylib.so file1.o file2.o
gcc main.c -L. -lmylib -o program
```
When running a program linked against a shared library not in a standard path, set:
```bash
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
```
## Run Compiled file
```bash
./compiled_program
```