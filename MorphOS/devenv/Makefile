# Makefile to build the SDL_mixer version 2

CC      = ppc-morphos-gcc-4 -noixemul 
#INCLUDE = -I../../../../include -I../sdk
CFLAGS  =  -mcpu=750 -mtune=7450 -O2 $(INCLUDE) -Wall -Wno-pointer-sign -fno-strict-aliasing
AR	= ar
RANLIB	= ranlib
TARGET = libSDL2_mixer.a

ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."

all: lib/$(TARGET) lib/libb32/$(TARGET) lib/libb32/libSDL2_mixer-nc.a

sdl-startup.o: sdl-startup.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -o $@ -c sdl-startup.c

sdl-startup-brel.o: sdl-startup.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -mresident32 -o $@ -c sdl-startup.c

sdl-startup-brel-nc.o: sdl-startup.c
	$(COMPILING)
	@$(CC) $(CFLAGS) -mresident32 -o $@ -c sdl-startup.c -D__NO_SDL_CONSTRUCTORS

lib/$(TARGET): sdl-startup.o ../sdk/fd/sdl2_mixer_lib.fd
	$(ARCHIVING)
	@mkdir -p lib
	@-rm -f $@
	@cvinclude.pl --fd ../sdk/fd/sdl2_mixer_lib.fd --clib ../sdk/clib/sdl2_mixer_protos.h --gluelib=$@
	@$(AR) cru $@ sdl-startup.o
	@ppc-morphos-ranlib $@

lib/libb32/$(TARGET): sdl-startup-brel.o  ../sdk/fd/sdl2_mixer_lib.fd
	$(ARCHIVING)
	@mkdir -p lib/libb32
	@-rm -f $@
	@cvinclude.pl --fd ../sdk/fd/sdl2_mixer_lib.fd --clib ../sdk/clib/sdl2_mixer_protos.h --brelgluelib=$@
	@$(AR) cru $@ sdl-startup-brel.o
	@ppc-morphos-ranlib $@

lib/libb32/libSDL2_mixer-nc.a: sdl-startup-brel-nc.o ../sdk/fd/sdl2_mixer_lib.fd
	$(ARCHIVING)
	@mkdir -p lib/libb32
	@-rm -f $@
	@cvinclude.pl --fd ../sdk/fd/sdl2_mixer_lib.fd --clib ../sdk/clib/sdl2_mixer_protos.h --brelgluelib=$@
	@$(AR) cru $@ sdl-startup-brel-nc.o
	@ppc-morphos-ranlib $@

clean:
	@-rm -rf lib *.s

dump:
	objdump --disassemble-all --reloc lib/$(TARGET).a >lib/libSDL2_mixer.s
