DISABLE_WARN := -Wno-switch -Wno-unused-value

CLANG_OPTS := -std=c++11 

EMCC_OPTS := --bind -s EXPORTED_FUNCTIONS="['_strlen']" -s EXPORTED_RUNTIME_METHODS="[]"
EMCC_OPTS += --pre-js src/pre.js --post-js src/post.js
EMCC_OPTS += --memory-init-file 0 -s TOTAL_MEMORY=16777216
EMCC_OPTS += -O3 --closure 1 --llvm-lto 1 -s NO_EXIT_RUNTIME=1 -s NO_FILESYSTEM=1

PXTONE_SRC := $(wildcard third_party/pxtone/*.cpp)


build/pxtnDecoder.js: src/* $(PXTONE_SRC) $(addprefix $(OGG_PREFIX), $(OGG_FILE)) $(addprefix $(VORBIS_PREFIX), $(VORBIS_FILE))
	mkdir -p build
	em++ src/bind.cpp $(PXTONE_SRC) $(CLANG_OPTS) $(EMCC_OPTS) $(DISABLE_WARN) -Ithird_party/pxtone -s USE_VORBIS=1 -o build/pxtnDecoder.js

clean:
	rm -rf build