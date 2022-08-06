import polyfill from './polyfill';
import {flipIt, getFlipperValue} from "./flipperContract";
import {getSigner} from "./util";

polyfill;

(window as any).onReefInjectedPromise = ()=>new Promise(resolve => {
    setTimeout(() => resolve(), 1000);
});

(window as any).flipperApi = {
    getSigner,
    flipIt: async (signer)=>{
        console.log("FLIPPING NOW");
        await flipIt(signer);
        const val = await getFlipperValue(signer);
        console.log('New value = ', val);
        return val;
    },
    getFlipperValue: async (signer) => {
        let val = await getFlipperValue(signer);
        console.log('Flipper value = ', val);
        return val;
    }
};
