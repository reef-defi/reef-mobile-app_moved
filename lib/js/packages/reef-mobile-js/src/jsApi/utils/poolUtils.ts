import { Signer as EvmProviderSigner, Provider } from "@reef-defi/evm-provider";
import { Contract } from "ethers";
import { ReefswapFactory } from "../abi/ReefswapFactory";
import { ReefswapPair } from "../abi/ReefswapPair";
import {tokenUtil} from "@reef-chain/util-lib"

export const getPoolReserves = async (token1Address: string, token2Address: string, provider: Provider, factoryAddress: string) => {
  const poolAddress = await findPoolTokenAddress(
    token1Address, token2Address, provider, factoryAddress);

  if (poolAddress === tokenUtil.EMPTY_ADDRESS||tokenUtil.EMPTY_ADDRESS.startsWith(poolAddress)) {
      console.log("NO POOL FOUND",);
      return false;
  }

  const poolContract = new Contract(poolAddress, ReefswapPair, provider);
  const reserves = await poolContract.getReserves();
  const address1 = await poolContract.token1();
  const [finalReserve1, finalReserve2] = token1Address !== address1
      ? [reserves[0], reserves[1]]
      : [reserves[1], reserves[0]];

  return {
      reserve1: finalReserve1.toString(),
      reserve2: finalReserve2.toString(),
  };
};

const findPoolTokenAddress = async (
  address1: string,
  address2: string,
  signerOrProvider: EvmProviderSigner | Provider,
  factoryAddress: string,
): Promise<string> => {
  const reefswapFactory = new Contract(factoryAddress, ReefswapFactory, signerOrProvider)
  const address = await reefswapFactory.getPair(address1, address2);
  return address;
};
