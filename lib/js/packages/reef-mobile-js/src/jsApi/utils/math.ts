import {BigNumber} from "ethers";

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

interface CalculateAmount {
    decimals: number;
    amount: string;
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
