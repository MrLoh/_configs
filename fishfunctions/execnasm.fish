function runasm --description 'compiles and runs assembler code with nasm'
  nasm -f macho64 $argv.asm
  ld -macosx_version_min 10.7.0 -lSystem -o $argv $argv.o
  chmod +x $argv
  eval ./$argv
end
