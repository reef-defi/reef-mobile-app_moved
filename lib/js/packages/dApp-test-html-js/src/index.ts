import polyfill from './polyfill';
import {web3Enable} from "@reef-defi/extension-dapp";
import {Provider, Signer as EvmSigner} from '@reef-defi/evm-provider';
import {WsProvider} from '@polkadot/rpc-provider';
import {ethers, Signer as EthersSigner} from 'ethers';

polyfill;

async function initProvider() {
    const URL = 'wss://rpc-testnet.reefscan.com/ws';
    const evmProvider = new Provider({
        provider: new WsProvider(URL)
    });
    await evmProvider.api.isReadyOrError;
    return evmProvider;
}

async function fliper(exeType: 'GET'|'SET', signer: EvmSigner) {
    const flipperContractAddressTestnet = '0x6252dC9516792DE316694D863271bd25c07E621B';

    const FlipperAbi = [
        {
            inputs: [
                {
                    internalType: 'bool',
                    name: 'initvalue',
                    type: 'bool'
                }
            ],
            stateMutability: 'nonpayable',
            type: 'constructor'
        },
        {
            inputs: [],
            name: 'flip',
            outputs: [],
            stateMutability: 'nonpayable',
            type: 'function'
        },
        {
            inputs: [],
            name: 'get',
            outputs: [
                {
                    internalType: 'bool',
                    name: '',
                    type: 'bool'
                }
            ],
            stateMutability: 'view',
            type: 'function'
        }
    ];
    const flipperContract = new ethers.Contract(flipperContractAddressTestnet, FlipperAbi, signer as EthersSigner);

    try {
        if(exeType==='SET') {
            const result = await flipperContract.flip();

            console.log(`Flipper SET TX: ${JSON.stringify(result)}`);
        }else {
            const result = await flipperContract.get();
            console.log('Flipper GET= ', result);
        }
    } catch {
        console.log('Value was not flipped! See console!');
    }
}

const main = async() => {
    const ext = await web3Enable('Test REEF DApp',[(window as any).reefMobileInjected || (()=>{return Promise.resolve(true)})]);
    // const web3accounts = await web3Accounts();
    // console.log("DAPP accounts RES=",web3accounts);
    let accounts = await ext[0].accounts.get();
    console.log("DAPP ACCOUNTS=",accounts);
    // const  signature = await ext[0].signer.signRaw({data: JSON.stringify({value:'hello'}), type:'bytes', address:'5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP'});
    // console.log("DAPP SIGN RESULT =",signature);

    const provider = await initProvider();
    const signer =  new EvmSigner(provider, accounts[0].address, ext[0].signer);

    await fliper('GET', signer);
    setTimeout(async ()=>{
        console.log("FLIPPING NOW");
        await fliper('SET', signer);
        console.log(await fliper('GET', signer));
    },2000);


}
main();


