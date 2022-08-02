import {BigNumber} from "ethers";

interface CalculateAmount {
    decimals: number;
    amount: string;
}

const assertAmount = (amount?: string): string => (!amount ? '0' : amount);

const findDecimalPoint = (amount: string): number => {
    const { length } = amount;
    let index = amount.indexOf(',');
    if (index !== -1) {
        return length - index - 1;
    }
    index = amount.indexOf('.');
    if (index !== -1) {
        return length - index - 1;
    }
    return 0;
};

const transformAmount = (decimals: number, amount: string): string => {
    if (!amount) {
        return '0'.repeat(decimals);
    }
    const addZeros = findDecimalPoint(amount);
    const cleanedAmount = amount.replace(/,/g, '').replace(/\./g, '');
    return cleanedAmount + '0'.repeat(Math.max(decimals - addZeros, 0));
};

const convert2Normal = (
    decimals: number,
    inputAmount: string,
  ): number => {
    const amount = '0'.repeat(decimals + 4) + assertAmount(inputAmount);
    const pointer = amount.length - decimals;
    const decimalPointer = `${amount.slice(0, pointer)}.${amount.slice(
      pointer,
      amount.length,
    )}`;
    return parseFloat(decimalPointer);
  };

const convert2String = (decimals: number, inputAmount: number): string => {
  var outputAmount = inputAmount.toLocaleString("en",{useGrouping: false, minimumFractionDigits: decimals, maximumFractionDigits: decimals});
  return outputAmount.startsWith("0.") ? outputAmount.replace("0.","") : outputAmount.replace(".","");
}

export const calculateAmount = ({ decimals, amount }: CalculateAmount): string => BigNumber.from(transformAmount(decimals, assertAmount(amount))).toString();

export const calculateAmountWithPercentage = (
    { amount: oldAmount, decimals }: CalculateAmount,
    percentage: number,
): string => {
    if (!oldAmount) {
      return '0';
    }
    const amount = parseFloat(assertAmount(oldAmount)) * (1 - percentage / 100);
    return calculateAmount({ amount: amount.toString(), decimals });
};

export const calculateDeadline = (minutes: number): number => Date.now() + minutes * 60 * 1000;

export const getOutputAmount = (inputAmountStr: string, token1Reserve: TokenWithAmount, token2Reserve: TokenWithAmount): string => {
    const inputAmount = parseFloat(assertAmount(inputAmountStr)) * 997;
  
    const inputReserve = convert2Normal(token1Reserve.decimals, token1Reserve.amount);
    const outputReserve = convert2Normal(token2Reserve.decimals, token2Reserve.amount);
  
    const numerator = inputAmount * outputReserve;
    const denominator = inputReserve * 1000 + inputAmount;
  
    return convert2String(token2Reserve.decimals, numerator/denominator);
  };
  
  export const getInputAmount = (outputAmountStr: string, token1Reserve: TokenWithAmount, token2Reserve: TokenWithAmount): string => {
    const outputAmount = parseFloat(assertAmount(outputAmountStr));
  
    const inputReserve = convert2Normal(token1Reserve.decimals, token1Reserve.amount);
    const outputReserve = convert2Normal(token2Reserve.decimals, token2Reserve.amount);
  
    const numerator = inputReserve * outputAmount * 1000;
    const denominator = (outputReserve - outputAmount) * 997;
  
    return convert2String(token1Reserve.decimals, numerator / denominator)
  };
