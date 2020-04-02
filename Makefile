# Makefile to build the SDL_mixer 2

CDEFS   =   -D__MORPHOS_SHAREDLIBS  -DHAVE_SNPRINTF -DHAVE_UNISTD_H -DHAVE_SETBUF -DHAVE_FORK  \
	    -DMUSIC_WAV -DMUSIC_OGG -DUSE_VORBISLIB -DMUSIC_MOD_MIKMOD -DMUSIC_MOD_MODPLUG
#   -DMUSIC_MAD -DMUSIC_MP3_MAD -DMUSIC_FLAC -DMUSIC_OPUS
#-DMUSIC_MID_NATIVE -DMUSIC_MID_TIMIDITY
#  
CC      = ppc-morphos-gcc-4  -noixemul
LIBS_EXT = -L/usr/local/lib -lmikmod -modplug
#  -lflac -lmad -lopusfile -lopus -lm
INCLUDE = -I../SDL-mos-sdl2/include -I. -I/usr/local/include -IMorphOS/sdk
CFLAGS  =  -mresident32 -mcpu=750 -mtune=7450 -Wno-pointer-sign -fno-strict-aliasing -O0 -Wall -ffast-math $(INCLUDE)  $(CDEFS)
# 

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

TARGET  = libSDL2_mixer.a
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
	cp MorphOS/devenv/lib/libSDL2_mixer.a /usr/local/lib/libSDL2_mixer.a
	cp MorphOS/devenv/lib/libb32/libSDL2_mixer.a /usr/local/lib/libb32/libSDL2_mixer.a

install: $(LIBRARY)
	@cp $(LIBRARY) LIBS:
	-flushlib $(LIBRARY)

MorphOS/MIX_library.o: MorphOS/MIX_library.c MorphOS/MIX_library.h MorphOS/MIX_stubs.h
	$(COMPILING)
	$(CC) -mcpu=750 -O0 $(INCLUDE) -Wall -fno-strict-aliasing -DAROS_ALMOST_COMPATIBLE -o $@ -c $*.c

$(TARGET): $(OBJECTS)
	$(ARCHIVING)
	@$(AR) crv $@ $^
	$(RANLIB) $@

$(LIBRARY): $(TARGET) $(COREOBJECTS)
	$(LINKING)
	$(CC) -nostartfiles -mresident32 -Wl,-Map=sdl2_mixer.map $(COREOBJECTS) -o $@.db -L. -lSDL2_mixer -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL2 -lm $(LIBS_EXT)
	#-lmad -logg -lvorbis -lmikmod -lflac
	$(STRIPPING)
	@ppc-morphos-strip -o $@ --remove-section=.comment $@.db

playwave: sdklibs playwave.c
	$(CC) -noixemul -O0 -Wall playwave.c -o $@ -I../SDL-mos-sdl2/include -DUSE_INLINE_STDARG  -LMorphOS/devenv/lib -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL2_mixer -lSDL2 $(LIBS_EXT)

playmus: sdklibs playmus.c
	$(CC) -noixemul -O0 -Wall playmus.c -o $@ -I../SDL-mos-sdl2/include -DUSE_INLINE_STDARG -LMorphOS/devenv/lib -L../SDL-mos-sdl2/src/core/morphos/devenv/lib -lSDL2_mixer -lSDL2  $(LIBS_EXT)

clean:
	rm -f $(LIBRARY) $(TARGET) $(OBJECTS) $(COREOBJECTS) *.db *.s

dump:
	objdump --disassemble-all --reloc $(LIBRARY).db >$(LIBRARY).s
