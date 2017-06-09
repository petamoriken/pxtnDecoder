INCLUDES := -Ithird_party/stdlib/include/libc -Ithird_party/stdlib/include/libcxx -Ithird_party/ogg/include -Ithird_party/vorbis/include -Ithird_party/vorbis/lib -Ithird_party/pxtone
DISABLE_WARN := -Wno-switch -Wno-unused-value -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses

OGG_PREFIX := third_party/ogg/src/
VORBIS_PREFIX := third_party/vorbis/lib/

OGG_FILE := bitwise.c framing.c
VORBIS_FILE := analysis.c bitrate.c block.c codebook.c envelope.c floor0.c floor1.c info.c lookup.c lpc.c lsp.c mapping0.c mdct.c psy.c registry.c res0.c sharedbook.c smallft.c synthesis.c vorbisenc.c vorbisfile.c window.c

PXTONE_SRC := $(wildcard third_party/pxtone/*.cpp)

build/pxtn.wasm: build/pxtn.wast
	wast2wasm build/pxtn.wast -o build/pxtn.wasm

build/pxtn.wast: build/pxtn.ll
	llc build/pxtn.ll -march=wasm32
	s2wasm build/pxtn.s --import-memory -o build/pxtn.wast

build/pxtn.ll: lib/main.ll $(foreach src, $(OGG_FILE), lib/$(basename $(src)).ll) $(foreach src, $(VORBIS_FILE), lib/$(basename $(src)).ll) $(foreach src, $(PXTONE_SRC), lib/$(basename $(notdir $(src))).ll)
	mkdir -p build
	llvm-link lib/*.ll -o build/pxtn.ll

define template
lib/$(basename $(notdir $2)).ll:
	mkdir -p lib
	$1 -emit-llvm -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c $(addprefix $3, $2) -o lib/$(basename $(notdir $2)).ll
endef

$(foreach src, $(OGG_FILE), $(eval $(call template, clang, $(src), $(OGG_PREFIX))))
$(foreach src, $(VORBIS_FILE), $(eval $(call template, clang, $(src), $(VORBIS_PREFIX))))

$(foreach src, $(PXTONE_SRC), $(eval $(call template, clang++, $(src))))

lib/main.ll: src/main.cpp third_party/ogg/include/ogg/config_types.h
	mkdir -p lib
	clang++ -emit-llvm -S --target=wasm32 $(INCLUDES) -Oz -c src/main.cpp -o lib/main.ll

third_party/ogg/include/ogg/config_types.h:
	cd third_party/ogg && ./autogen.sh && ./configure

clean:
	rm -rf lib build