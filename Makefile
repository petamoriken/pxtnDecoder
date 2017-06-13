DISABLE_WARN := -Wno-switch -Wno-unused-value -Wno-bitwise-op-parentheses -Wno-shift-op-parentheses -Wno-macro-redefined -Wno-missing-exception-spec -Wno-ignored-attributes
OPTS := -O3

PXTONE_SRC := $(wildcard third_party/pxtone/*.cpp)


build/empxtn.wasm: src/*.cpp $(PXTONE_SRC) $(addprefix $(OGG_PREFIX), $(OGG_FILE)) $(addprefix $(VORBIS_PREFIX), $(VORBIS_FILE))
	mkdir -p build
	em++ -std=c++11 src/*.cpp $(PXTONE_SRC) $(OPTS) -Ithird_party/pxtone -s USE_VORBIS=1 -s WASM=1 -s SIDE_MODULE=1 -o build/empxtn.wasm $(DISABLE_WARN)