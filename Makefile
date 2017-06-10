INCLUDES := -Ithird_party/stdlib/include/libc -Ithird_party/stdlib/src/internal -Ithird_party/stdlib/include/libcxx -Ithird_party/ogg/include -Ithird_party/vorbis/include -Ithird_party/vorbis/lib -Ithird_party/pxtone
DISABLE_WARN := -Wno-switch -Wno-unused-value -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses -Wno-macro-redefined -Wno-missing-exception-spec -Wno-ignored-attributes

MALLOC_OPTS = -DMORECORE_CANNOT_TRIM=1 -DHAVE_MMAP=0 -DHAVE_MREMAP=0 -DLACKS_TIME_H=1 -DNO_MALLOC_STATS=1 -Dmalloc_getpagesize=65536 -Wno-expansion-to-defined

OGG_PREFIX := third_party/ogg/src/
VORBIS_PREFIX := third_party/vorbis/lib/
STDLIB_PREFIX := third_party/stdlib/src/

OGG_FILE := bitwise.c framing.c
VORBIS_FILE := analysis.c bitrate.c block.c codebook.c envelope.c floor0.c floor1.c info.c lookup.c lpc.c lsp.c mapping0.c mdct.c psy.c registry.c res0.c sharedbook.c smallft.c synthesis.c vorbisenc.c vorbisfile.c window.c
STDLIB_FILE := $(addprefix stdio/, fread.c fwrite.c fseek.c ftell.c __toread.c __towrite.c) $(addprefix stdlib/, qsort.c) $(addprefix string/, memchr.c memcmp.c memcpy.c memset.c memmove.c strcat.c strlen.c) $(addprefix ctype/, toupper.c islower.c)

PXTONE_SRC := $(wildcard third_party/pxtone/*.cpp)


build/pxtn.wasm: lib/main.ll lib/new.ll lib/dlmalloc.ll $(foreach src, $(OGG_FILE), lib/$(basename $(src)).ll) $(foreach src, $(VORBIS_FILE), lib/$(basename $(src)).ll) $(foreach src, $(PXTONE_SRC), lib/$(basename $(notdir $(src))).ll) $(foreach src, $(STDLIB_FILE), lib/$(basename $(notdir $(src))).ll)
	mkdir -p build
	llvm-link lib/*.ll -o build/pxtn.ll
	llc build/pxtn.ll -march=wasm32
	rm build/pxtn.ll
	s2wasm build/pxtn.s --import-memory -o build/pxtn.wast
	rm build/pxtn.s
	wast2wasm build/pxtn.wast -o build/pxtn.wasm

define template_c
lib/$(basename $(notdir $1)).ll:
	mkdir -p lib
	clang -emit-llvm -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c $(addprefix $2, $1) -o lib/$(basename $(notdir $1)).ll
endef

$(foreach src, $(OGG_FILE), $(eval $(call template_c, $(src), $(OGG_PREFIX))))
$(foreach src, $(VORBIS_FILE), $(eval $(call template_c, $(src), $(VORBIS_PREFIX))))
$(foreach src, $(STDLIB_FILE), $(eval $(call template_c, $(src), $(STDLIB_PREFIX))))

define template_cpp
lib/$(basename $(notdir $1)).ll:
	mkdir -p lib
	clang++ -emit-llvm -S --target=wasm32 -fno-sized-deallocation $(INCLUDES) $(DISABLE_WARN) -Oz -c $(addprefix $2, $1) -o lib/$(basename $(notdir $1)).ll
endef

$(foreach src, $(PXTONE_SRC), $(eval $(call template_cpp, $(src))))

lib/dlmalloc.ll:
	clang -emit-llvm -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c $(STDLIB_PREFIX)dlmalloc.c -o lib/dlmalloc.ll $(MALLOC_OPTS)

lib/new.ll: src/new.cpp
	mkdir -p lib
	clang++ -emit-llvm -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c src/new.cpp -o lib/new.ll	

lib/main.ll: src/main.cpp third_party/ogg/include/ogg/config_types.h
	mkdir -p lib
	clang++ -emit-llvm -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c src/main.cpp -o lib/main.ll

third_party/ogg/include/ogg/config_types.h:
	cd third_party/ogg && ./autogen.sh && ./configure

clean:
	rm -rf lib build