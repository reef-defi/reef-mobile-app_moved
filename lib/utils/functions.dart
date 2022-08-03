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

// TODO: remove? not used
String toAmountDisplayString(String decimalsString, {int decimals = 18, int fractionDigits = 4}) => (BigInt.parse(decimalsString)/BigInt.from(10).pow(decimals)).toStringAsFixed(fractionDigits);
String toAmountDisplayBigInt(BigInt decimalsVal, {int decimals = 18, int fractionDigits = 4}) => (decimalsVal/BigInt.from(10).pow(decimals)).toStringAsFixed(fractionDigits);
double decimalsToDouble(BigInt decimalsVal, {int decimals = 18}) => (decimalsVal/BigInt.from(10).pow(decimals)).toDouble();

String toStringWithoutDecimals(String amount, int decimals) {
  var arr = amount.split(".");

  var intPart = arr[0];
  if (arr.length == 1) {
    for (int i = 0; i < decimals; i++) {
      intPart += "0";
    }
    return intPart;
  }

  while (intPart.startsWith("0")) {
    intPart = intPart.substring(1);
  }

  var fractionalPart = arr[1];
  while (fractionalPart.length < decimals) {
    fractionalPart += "0";
  }

  return intPart + fractionalPart;
}