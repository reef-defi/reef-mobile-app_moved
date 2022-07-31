double getBalanceValue(double balance, price) {
  if(price == null || price == null){
    return 0.0;
  }
  return balance * price;
}

extension CapitalizeExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension ShortenExtension on String {
  String shorten() {
    return "${substring(0, 2)}...${substring(length - 5)}";
  }
}

String toBalanceDisplayString(String decimalsString) => (BigInt.parse(decimalsString)/BigInt.from(10).pow(18)).toString();
String toBalanceDisplayBigInt(BigInt decimalsVal) => (decimalsVal/BigInt.from(10).pow(18)).toString();
double decimalsToDouble(BigInt decimalsVal, {int decimals = 18}) => (decimalsVal/BigInt.from(10).pow(decimals)).toDouble();

