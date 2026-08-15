@echo off
set EMXOMFLD_TYPE=WLINK
set EMXOMFLD_LINKER=wl.exe
set EMXOMFLD_PRELINK=0
make -f makefile.os2 %1 %2 > compile.log 2>&1
type compile.log
