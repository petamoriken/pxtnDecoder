INCLUDES := -Ithird_party/stdlib/include/libc -Ithird_party/stdlib/include/libcxx -Ithird_party/ogg/include -Ithird_party/vorbis/include -Ithird_party/vorbis/lib -Ithird_party/pxtone
DISABLE_WARN := -Wno-switch -Wno-unused-value -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses

PXTONE_SRC := $(wildcard third_party/pxtone/*.cpp)
OGG_SRC := $(addprefix third_party/ogg/src/, bitwise.c framing.c)
VORVIS_SRC := $(addprefix third_party/vorbis/lib/, analysis.c bitrate.c block.c codebook.c envelope.c floor0.c floor1.c info.c lookup.c lpc.c lsp.c mapping0.c mdct.c psy.c registry.c res0.c sharedbook.c smallft.c synthesis.c vorbisenc.c vorbisfile.c window.c)


lib/main.ll: third_party/ogg/include/ogg/config_types.h
	mkdir -p lib
	clang++ -S --target=wasm32 $(INCLUDES) -Oz -c src/main.cpp -o lib/main.ll
	$(foreach src, $(OGG_SRC), clang -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c $(src) -o lib/$(basename $(notdir $(src))).ll;)
	$(foreach src, $(VORVIS_SRC), clang -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c $(src) -o lib/$(basename $(notdir $(src))).ll;)
	$(foreach src, $(PXTONE_SRC), clang++ -S --target=wasm32 $(INCLUDES) $(DISABLE_WARN) -Oz -c $(src) -o lib/$(basename $(notdir $(src))).ll;)

third_party/ogg/include/ogg/config_types.h:
	cd third_party/ogg && ./autogen.sh && ./configure

clean:
	rm -rf lib