#include <new>
#include <cstdlib>

#define Error "operator new error"

extern "C" void consoleError(const char* offset, size_t length);

void* operator new (size_t size) throw(std::bad_alloc) {
    if(size == 0)
        size = 1;

    void* ptr = malloc(size);

    if(ptr == nullptr) {
        consoleError(Error, sizeof(Error));
    }

    return ptr;
}

void operator delete(void* ptr) throw() {
    free(ptr);
}