#include <cstddef>
#include <string>

#include <pxtnService.h>
#include <pxtnError.h>

extern "C" {

void consoleError(const char *offset, size_t length);

static void printError(pxtnERR pxtn_err) {
    const char* err = pxtnError_get_string(pxtn_err);
    size_t length = strlen(err);

    consoleError(err, length);
}

pxtnService* service_create(int32_t channel, int32_t sample_per_second) {
    pxtnService* pxtn = nullptr;
    pxtnERR pxtn_err = pxtnERR_VOID;

    pxtn = new pxtnService();
    pxtn_err = pxtn->init();

    if(pxtn_err != pxtnOK)
        goto End;

    pxtn->set_destination_quality(channel, sample_per_second);

End:
    if(pxtn_err != pxtnOK) {
        printError(pxtn_err);
        SAFE_DELETE(pxtn);
        return nullptr;
    }

    return pxtn;
}

bool service_load(pxtnService* pxtn, void* buffer, int length) {
    bool b_ret = false;

    pxtnERR pxtn_err = pxtnERR_VOID;
    pxtnDescriptor desc;

    if(!desc.set_memory_r(buffer, length))
        goto End;
    
    pxtn_err = pxtn->read(&desc);
    if(pxtn_err != pxtnOK)
        goto End;
    
    pxtn_err = pxtn->tones_ready();
    if(pxtn_err != pxtnOK)
        goto End;

    b_ret = true;

End:
    if(!b_ret) {
        printError(pxtn_err);
        pxtn->evels->Release();
    }
    
    return b_ret;
}

const char* service_getName(pxtnService* pxtn) {
    return pxtn->text->get_name_buf(nullptr);
}

const char* service_getComment(pxtnService* pxtn) {
    return pxtn->text->get_comment_buf(nullptr);
}

void service_delete(pxtnService *pxtn) {
    SAFE_DELETE(pxtn);
}

}