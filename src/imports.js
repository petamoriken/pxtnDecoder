const memory = new WebAssembly.Memory({
    initial: 256
});

const imports = {

    consoleError(offset, length) {
        const buffer = new Uint8Array(memory.length, offset, length);
        console.log(new TextDecoder().decode(buffer));
    },

    memory,

    sbrk(num) {
        return memory.grow(num);
    },

    abort() {
        console.log("abort");
    },

    exit() {
        console.log("exit");
    },

    _ZSt9terminatev() {
        console.log("terminate");
    },

    _ZTISt9bad_alloc() {
        console.log("bad alloc");
    },

    __cxa_begin_catch(num) {
        console.log("begin catch:", num);
        return 0;
    },

    __errno_location() {
        return 0;
    },

    __lockfile(num) {
        console.log("lock:", num);
        return 1;
    },

    __unlockfile(num) {
        console.log("unlock:", num);
    },

    __stdio_exit_needed() {
        console.log("stdio exit needed");
    },

    fopen() {
        console.log("fopen");
        return 0;
    },

    fclose() {
        console.log("fclose");
        return 0;
    },

    acos: Math.acos,
    atan: Math.atan,
    sin: Math.sin,
    cos: Math.cos,
    exp: Math.exp,
    log: Math.log,
    pow: Math.pow,

    // http://croquetweak.blogspot.jp/2014/08/deconstructing-floats-frexp-and-ldexp.html    
    ldexp(mantissa, exponent) {
        const steps = Math.min(3, Math.ceil(Math.abs(exponent) / 1023));
        let result = mantissa;
        for (let i = 0; i < steps; ++i) {
            result *= 2 ** Math.floor((exponent + i) / steps);
        }
        return result;
    },

    strcpy(target, start) {
        const buffer = new Uint8Array(memory.buffer);

        let end = start;
        for(;;) {
            if(buffer[end++] === 0) {
                break;
            }
        }

        buffer.copyWithin(target, start, end);
    }

}
