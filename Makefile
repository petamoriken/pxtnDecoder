PXTONE_DIR:=pxtone_source
EMCC_DIR:=emscripten_source

CLANG_OPTS:=-std=c++11 -Wno-unused-value -Wno-switch -Wno-parentheses

EMCC_OPTS:=--bind -s EXPORTED_RUNTIME_METHODS="['getValue']"
EMCC_OPTS+=-s DISABLE_EXCEPTION_CATCHING=1 -s NO_EXIT_RUNTIME=1 -s NO_FILESYSTEM=1
EMCC_OPTS+=-s TOTAL_MEMORY=16777216
EMCC_OPTS+=-Oz --memory-init-file 0 --closure 1
EMCC_OPTS+=--pre-js $(EMCC_DIR)/pre.js --post-js $(EMCC_DIR)/post.js

EMCC_LINKS:=-I $(PXTONE_DIR)/src-oggvorbis -I $(PXTONE_DIR)/src-pxtone -I $(PXTONE_DIR)/src-pxtonePlay -I $(PXTONE_DIR)/src-pxwr

EMCC_SRCS:=-x c $(wildcard $(PXTONE_DIR)/src-oggvorbis/*.c) $(PXTONE_DIR)/src-oggvorbis/.libs/libvorbis.a
EMCC_SRCS+=-x c++ $(EMCC_DIR)/bind.cpp $(wildcard $(PXTONE_DIR)/src-pxtone/*.cpp) $(wildcard $(PXTONE_DIR)/src-pxtonePlay/*.cpp) $(wildcard $(PXTONE_DIR)/src-pxwr/*.cpp)


all: lib/* build/pxtnDecoder.min.js

build/pxtnDecoder.min.js: build/pxtnDecoder.js
	uglifyjs build/pxtnDecoder.js -c --comments "/pxtnDecoder/" -o build/pxtnDecoder.min.js 

build/pxtnDecoder.js: src/* src/emDecoder.js
	mkdir -p build temp && \
	browserify -t babelify src/index.js --no-commondir --igv global -i text-encoding -o temp/pxtnDecoder.js && \
	echo "/*! pxtnDecoder" v`node -pe "require('./package.json').version"` "http://git.io/pxtnDecoder */" | cat - temp/pxtnDecoder.js > build/pxtnDecoder.js && \
	$(RM) -rf temp

lib/*: src/* src/emDecoder.js
	babel src --ignore "emDecoder.js" -d lib && \
	cp src/emDecoder.js lib/emDecoder.js

src/emDecoder.js: $(PXTONE_DIR)/src-pxtone/* $(PXTONE_DIR)/src-pxtonePlay/* $(PXTONE_DIR)/src-pxwr/* $(EMCC_DIR)/*
	em++ $(CLANG_OPTS) $(EMCC_OPTS) $(EMCC_LINKS) $(EMCC_SRCS) -o src/emDecoder.js

clean:
	$(RM) -rf build lib temp src/emDecoder.js
