import { reefTokenWithAmount } from "@reef-defi/react-lib";

export enum DataProgress {
    LOADING = 'DataProgress_LOADING',
    NO_DATA = 'DataProgress_NO_DATA',
  }
  
export type DataWithProgress<T> = T | DataProgress;

export const EMPTY_ADDRESS = '0x0000000000000000000000000000000000000000';

export const REEF_ADDRESS = reefTokenWithAmount().address;

export const isDataSet = (dataOrProgress: DataWithProgress<any>): boolean => !Object.keys(DataProgress).some((k:string) => (DataProgress as any)[k] === dataOrProgress);

export const uniqueCombinations = <T>(array: T[]): [T, T][] => {
  const result: [T, T][] = [];
  for (let i = 0; i < array.length; i += 1) {
    for (let j = i + 1; j < array.length; j += 1) {
      result.push([array[i], array[j]]);
    }
  }
  return result;
};

export const ensure = (condition: boolean, message: string): void => {
  if (!condition) {
    throw new Error(message);
  }
};