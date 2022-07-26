interface Token {
    address: string;
    decimals: number;
}

interface TokenWithAmount extends Token {
    amount: string;
}