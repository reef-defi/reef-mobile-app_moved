import polyfill from './polyfill';
import {web3Enable} from "@reef-defi/extension-dapp";

polyfill;

const main = async() => {
    const ext = await web3Enable('Test REEF DApp');
    console.log("hello dapp111=");
}
main();

