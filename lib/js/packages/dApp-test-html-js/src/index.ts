import polyfill from './polyfill';
import {web3Accounts, web3Enable} from "@reef-defi/extension-dapp";
import {getExtensionSigners} from "../../../../../../../test/lib3/src/rpc";

polyfill;

const main = async() => {
    const ext = await web3Enable('Test REEF DApp',[(window as any).reefMobileInjected || (()=>{return Promise.resolve(true)})]);
    // console.log("hello dapp=", ext[0].signer));
    console.dir( ext[0].signer);
    const web3accounts = await web3Accounts();
    console.log("DAPP accounts=",web3accounts.length);
    // await extension.accounts.get();
}
main();


