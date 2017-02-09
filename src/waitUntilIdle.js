import "requestidlecallback";
import { ENVIRONMENT } from "./emDecoder";

const ENVIRONMENT_IS_WORKER = ENVIRONMENT === "WORKER";

export default function waitUntilIdle() {
    return new Promise(resolve => {
        if(ENVIRONMENT_IS_WORKER)
            resolve();
        
        requestIdleCallback(resolve);
    });
}