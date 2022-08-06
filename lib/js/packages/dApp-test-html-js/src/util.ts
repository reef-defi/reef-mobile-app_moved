import {Provider} from "@reef-defi/evm-provider";
import {WsProvider} from "@polkadot/rpc-provider";
import {Signer as EthersSigner} from "@ethersproject/abstract-signer";
import {BigNumber, ethers} from "ethers";
import {Signer as EvmSigner} from "@reef-defi/evm-provider/Signer";
import {web3Enable} from "@reef-defi/extension-dapp";

async function initProvider() {
    const URL = 'wss://rpc-testnet.reefscan.com/ws';
    const evmProvider = new Provider({
        provider: new WsProvider(URL)
    });
    await evmProvider.api.isReadyOrError;
    return evmProvider;
}

export async function initExtension() {
    const ext = await web3Enable('Test REEF DApp', [(window as any).onReefInjectedPromise || (() => {
        return Promise.resolve(true);
    })]);
    if (!ext.length) {
        alert('Install Reef Chain Wallet extension for Chrome or Firefox. See docs.reef.io')
        return;
    }
    const extension = ext[0];
    // console.log("Accounts from all extensions=",await web3Accounts());

    console.log("Extension=", extension.name);
    const accounts = await extension.accounts.get();
    if(!accounts.length){
        alert('Create or import account in extension.')
        return;
    }
    let testAccount = accounts.find(a => a.address === '5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP');
    if(!testAccount){
        testAccount = accounts[0];
    }
    console.log("USING ACCOUNT=", testAccount?testAccount.address:'Test account not found');
    return {extension, testAccount};
}

export async function initSigner(address: String, extensionSigner) {
    const provider = await initProvider();
    return  new EvmSigner(provider, address, extensionSigner);
}


function getReefDecimals() {
    return BigNumber.from('10').pow('18');
}

export const getSigner = async () => {
    let {extension, testAccount} = await initExtension();
    // const  signature = await extension.signer.signRaw({data: JSON.stringify({value:'hello'}), type:'bytes', address:testAccount.address});
    // console.log("DAPP SIGN RESULT =", signature);

    const signer = await initSigner(testAccount.address, extension.signer);

    const balanceBigNumber = await signer.getBalance();
    const balance = balanceBigNumber.div(getReefDecimals());
    if(balance.lt( '3') ){
        alert('Balance should be at least 3 for transaction. Check the docs.reef.io how to get testnet REEF coins.');
    }
    console.log("Signer balance=",balance.toString());

    const hasEvmAddress = await signer.isClaimed();
    if(!hasEvmAddress){
        // create EVM address for smart contract interaction
        await signer.claimDefaultAccount();
    }
    // console.log("account evm address=", await signer.queryEvmAddress());
    return signer;
}
