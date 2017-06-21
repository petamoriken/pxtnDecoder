#include <string>

#include <emscripten/bind.h>

#include <pxtnService.h>
#include <pxtnError.h>

using namespace emscripten;


uintptr_t descriptor_create(uintptr_t buffer_ptr, int32_t length) {
    void* buffer = (void*) buffer_ptr;

    pxtnDescriptor* desc = new pxtnDescriptor();

    if(!desc->set_memory_r(buffer, length)) {
        SAFE_DELETE(desc);
        return NULL;
    }
    
    return (uintptr_t)desc;
}

bool descriptor_delete(uintptr_t pxtn_ptr) {
    pxtnDescriptor* pxtn = (pxtnDescriptor*) pxtn_ptr;

    SAFE_DELETE(pxtn);

    return true;
}


uintptr_t service_create(int32_t channel, int32_t sample_per_second) {
    pxtnService* pxtn = NULL;
    pxtnERR pxtn_err = pxtnERR_VOID;

    pxtn = new pxtnService();
    pxtn_err = pxtn->init();   

    if(pxtn_err != pxtnOK)
        goto End;

    pxtn->set_destination_quality(channel, sample_per_second);

End:
    if(pxtn_err != pxtnOK) {
        SAFE_DELETE(pxtn);
        return NULL;
    }

    return (uintptr_t)pxtn;
}

bool service_load(uintptr_t pxtn_ptr, uintptr_t desc_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;
    pxtnDescriptor* desc = (pxtnDescriptor*) desc_ptr;

    bool b_ret = false;

    pxtnERR pxtn_err = pxtnERR_VOID;

    if(pxtn_ptr == NULL)
        goto End;
    
    pxtn_err = pxtn->read(desc);
    if(pxtn_err != pxtnOK)
        goto End;
    
    pxtn_err = pxtn->tones_ready();
    if(pxtn_err != pxtnOK)
        goto End;
    


    b_ret = true;

End:
    if(!b_ret) {
        pxtn->evels->Release();
    }
    
    return b_ret;
}

bool service_proparation(uintptr_t pxtn_ptr, int32_t start_sample) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;    
    pxtnVOMITPREPARATION prep = {0};

    prep.master_volume = 1.0f;
    prep.start_pos_sample = start_sample;

    return pxtn->moo_preparation(&prep);
}

uintptr_t service_getName(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    if(pxtn_ptr == NULL)
       return NULL;

    return (uintptr_t)pxtn->text->get_name_buf(NULL);
}

uintptr_t service_getComment(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    if(pxtn_ptr == NULL)
       return NULL;
    
    return (uintptr_t)pxtn->text->get_comment_buf(NULL);
}

int32_t service_getTotalSample(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    if(pxtn_ptr == NULL)
       return 0;

    return pxtn->moo_get_total_sample();
}

bool service_vomit(uintptr_t pxtn_ptr, uintptr_t buffer_ptr, int32_t size) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;
    void* buffer = (void*) buffer_ptr;

    if(pxtn_ptr == NULL)
       return false;

    return pxtn->Moo(buffer, size);
}

/*
int32_t service_getMeasNum(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    if(pxtn_ptr == NULL)
       return 0;

    return pxtn->master->get_meas_num();
}

int32_t service_getRepeatMeas(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    if(pxtn_ptr == NULL)
       return 0;

    return pxtn->master->get_repeat_meas();
}

int32_t service_getLastMeas(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    if(pxtn_ptr == NULL)
       return 0;

    return pxtn->master->get_last_meas();
}
*/

bool service_delete(uintptr_t pxtn_ptr) {
    pxtnService* pxtn = (pxtnService*) pxtn_ptr;

    SAFE_DELETE(pxtn);

    return true;
}


EMSCRIPTEN_BINDINGS(pxtn) {

    function("descriptor_create", &descriptor_create);
    function("descriptor_delete", &descriptor_delete);

    function("service_create", &service_create);
    function("service_load", &service_load);
    function("service_proparation", &service_proparation);
    function("service_getName", &service_getName);
    function("service_getComment", &service_getComment);
    function("service_getTotalSample", &service_getTotalSample);
    function("service_vomit", &service_vomit);
    function("service_delete", &service_delete);

}