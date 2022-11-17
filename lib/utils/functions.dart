import 'dart:convert';

double getBalanceValue(double balance, price) {
  if (price == null || price == null) {
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

String toAmountDisplayBigInt(BigInt decimalsVal,
    {int decimals = 18, int fractionDigits = 0}) {
  BigInt divisor = BigInt.from(10).pow(decimals);
  String intPart = (decimalsVal ~/ BigInt.from(10).pow(decimals)).toString();
  if (fractionDigits == 0) return intPart;
  String fractionalPart =
      decimalsVal.remainder(divisor).toString().padLeft(decimals, "0");
  fractionalPart = fractionalPart.length < fractionDigits
      ? fractionalPart.padRight(fractionDigits, "0")
      : fractionalPart.substring(0, fractionDigits);
  return "$intPart.$fractionalPart";
}

double decimalsToDouble(BigInt decimalsVal, {int decimals = 18}) =>
    (decimalsVal / BigInt.from(10).pow(decimals)).toDouble();

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

// To check for valid checksum use JS utility
bool isEvmAddress(String address) {
  return RegExp(r'^(0x|0X)([0-9a-fA-F]{40})$').hasMatch(address);
}

// To check for valid checksum use JS utility
bool isSubstrateAddress(String address) {
  if (address.isEmpty || !address.startsWith("5")) {
    return false;
  }
  return RegExp(r'^[A-z\d]{48}$').hasMatch(address);
}

String stripUrl(String? url) {
  if (url != null &&
      (url.startsWith('http:') ||
          url.startsWith('https:') ||
          url.startsWith('ipfs:') ||
          url.startsWith('ipns:'))) {
    return url.split("/")[2];
  }
  return '';
}

String hexToDecimalString(String hex) {
  return BigInt.parse(hex.substring(2), radix: 16).toString();
}
