import polyfill from './polyfill';
import {web3Enable} from "@reef-defi/extension-dapp";

polyfill;

const main = async() => {
    const ext = await web3Enable('Test REEF DApp',[(window as any).reefMobileInjected || (()=>{return Promise.resolve(true)})]);
    console.log("hello dapp111=", ext.map((e)=>e.signer));
}
main();


