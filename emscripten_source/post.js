// ENVIRONMENT
Module["ENVIRONMENT"] = ENVIRONMENT_IS_WEB ? "WEB" :
                        ENVIRONMENT_IS_WORKER ? "WORKER" :
                        ENVIRONMENT_IS_NODE ? "NODE" : "SHELL";

Module["getNativeTypeSize"] = Runtime.getNativeTypeSize;

// export for browserify
if(!ENVIRONMENT_IS_NODE)
    module["exports"] = Module;

// closure
}();