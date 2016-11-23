function runc
  clang -o $argv $argv.c
  eval ./$argv
end
