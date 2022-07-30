// TODO remove default value
double getUSDPrice(double reefPrice, {conversionRate = 0.003272}) {
  return reefPrice * conversionRate;
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
String toBalanceDisplayBigInt(BigInt decimalsString) => (decimalsString/BigInt.from(10).pow(18)).toString();

