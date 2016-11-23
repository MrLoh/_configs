function runasm2c
  clang -c -o $argv.c.o $argv.c
  nasm -f macho64 -o $argv.s.o $argv.asm
  clang -o $argv.out $argv.s.o $argv.c.o
  eval ./$argv.out
end
