# Makefile to build the SDL_mixer 2

CDEFS   =  -DAROS_ALMOST_COMPATIBLE  -DHAVE_SNPRINTF -DHAVE_UNISTD_H -DHAVE_SETBUF -DHAVE_FORK  \
					-DMUSIC_WAV -DMUSIC_OGG -DMUSIC_FLAC -DMUSIC_MOD_MIKMOD -DMUSIC_MAD
#-DUSE_INLINE_STDARG -D__MORPHOS_SHAREDLIBS -D_NO_INLINEPPC
#-DMUSIC_MID_NATIVE -DMUSIC_MID_TIMIDITY
#-DMUSIC_MP3_MAD  -DMUSIC_MOD_MODPLUG -DMUSIC_OPUS
CC      = ppc-morphos-gcc-4 -noixemul
INCLUDE = -I../SDL-mos-sdl2/include -I. -I/usr/local/include -IMorphOS/sdk
CFLAGS  =  -mcpu=750 -mtune=7450 -Wno-pointer-sign -fno-strict-aliasing -O2 -Wall -ffast-math $(INCLUDE)  $(CDEFS)
# -mresident32

AR      = ar
RANLIB  = ranlib

ECHE = echo -e
BOLD = \033[1m
NRML = \033[22m

COMPILING = @$(ECHE) "compiling $(BOLD)$@$(NRML)..."
LINKING = @$(ECHE) "linking $(BOLD)$@$(NRML)..."
STRIPPING = @$(ECHE) "stripping $(BOLD)$@$(NRML)..."
ARCHIVING = @$(ECHE) "archiving $(BOLD)$@$(NRML)..."
HEADERING = @$(ECHE) "creating headers files $(BOLD)$@$(NRML)..."

TARGET  = libSDL_mixer.a
LIBRARY = sdl2_mixer.library

SOURCES = \
	mixer.c \
	effect_stereoreverse.c \
	effects_internal.c \
	effect_position.c \
	load_aiff.c \
	load_voc.c \
	music.c \
	music_cmd.c \
	music_flac.c \
	music_fluidsynth.c \
	music_mad.c \
	music_mikmod.c \
	music_modplug.c \
	music_mpg123.c \
	music_nativemidi.c \
	music_opus.c \
	music_ogg.c \
	music_timidity.c \
	music_wav.c \
	timidity/common.c timidity/instrum.c timidity/mix.c timidity/output.c \
	timidity/playmidi.c timidity/readmidi.c timidity/resample.c \
	timidity/tables.c timidity/timidity.c 
		 	

CORESOURCES = MorphOS/*.c
COREOBJECTS = $(shell echo $(CORESOURCES) | sed -e 's,\.c,\.o,g')

OBJECTS = $(shell echo $(SOURCES) | sed -e 's,\.c,\.o,g')

all: $(LIBRARY) sdklibs

headers:
	$(HEADERING)
	@cvinclude.pl --fd=MorphOS/sdk/fd/sdl2_mixer_lib.fd --clib=MorphOS/sdk/clib/sdl2_mixer_protos.h --proto=MorphOS/sdk/proto/sdl2_mixer.h --verbose
	@cvinclude.pl --fd=MorphOS/sdk/fd/sdl2_mixer_lib.fd --clib=MorphOS/sdk/clib/sdl2_mixer_protos.h --inline=MorphOS/sdk/ppcinline/sdl2_mixer.h

sdklibs:
	@cd MorphOS/devenv; if ! $(MAKE) all; then exit 1; fi;

sdk: sdklibs
	cp SDL_mixer.h /usr/local/include/SDL2
	cp MorphOS/devenv/lib/libSDL_mixer.a /usr/local/lib/libSDL2_mixer.a
	cp MorphOS/devenv/lib/libb32/libSDL_mixer.a /user/local/lib/libb32/libSDL2_mixer.a

install: $(LIBRARY)
	@cp $(LIBRARY) LIBS:
	-flushlib $(LIBRARY)

install-iso: $(LIBRARY)
	mkdir -p $(ISOPATH)MorphOS/Libs/
	@cp $(LIBRARY) $(ISOPATH)MorphOS/Libs/

MorphOS/MIX_library.o: MorphOS/MIX_library.c MorphOS/MIX_library.h MorphOS/MIX_stubs.h
	$(COMPILING)
	$(CC) -mcpu=750 -O2 $(INCLUDE) -Wall -fno-strict-aliasing -DAROS_ALMOST_COMPATIBLE -o $@ -c $*.c

$(TARGET): $(OBJECTS)
	$(ARCHIVING)
	@$(AR) crv $@ $^
	$(RANLIB) $@

$(LIBRARY): $(TARGET) $(COREOBJECTS)
	$(LINKING)
	$(CC) -nostartfiles -mresident32 -Wl,-Map=sdl2_mixer.map $(COREOBJECTS) -o $@.db -L. -LSDL_mixer -L/usr/local/lib -lSDL2 -lm -lflac -lmikmod -lvorbis -logg -lmad
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

playwave: sdklibs playwave.c
	$(CC) -noixemul -O2 -Wall playwave.c -o $@ -I../SDL-mos-sdl2/include -DUSE_INLINE_STDARG  -LMorphOS/devenv/lib -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL_mixer -lSDL -lflac -lmikmod -lvorbis -logg -lmad

playmus: sdklibs playmus.c
	$(CC) -noixemul -O2 -Wall playmus.c -o $@ -I../SDL-mos-sdl2/include -DUSE_INLINE_STDARG -LMorphOS/devenv/lib -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL_mixer -lSDL -lflac -lmikmod -lvorbis -logg -lmad



clean:
	rm -f $(LIBRARY) $(TARGET) $(OBJECTS) $(COREOBJECTS) *.db *.s

dump:
	objdump --disassemble-all --reloc $(LIBRARY).db >$(LIBRARY).s
