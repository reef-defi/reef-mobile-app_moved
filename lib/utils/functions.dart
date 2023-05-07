import 'package:intl/intl.dart';
import 'package:reef_mobile_app/utils/constants.dart';

T? cast<T>(x) => x is T ? x : null;

double getBalanceValue(double balance, price) {
  if (price == null || balance == null) {
    return 0.0;
  }
  return balance * price;
}

double getBalanceValueBI(BigInt? balance, double? price) {
  if (price == null || balance == null) {
    return 0.0;
  }
  var priceSplit = price.toString().split('.');
  var decimalPlaces = priceSplit.length == 2 ? priceSplit[1].length : 0;
  var res = ((balance * BigInt.parse(priceSplit[0] + (priceSplit[1] ?? ''))) /
          BigInt.from(10).pow(decimalPlaces)) /
      BigInt.from(10).pow(18).toDouble();
  return res;
}

extension CapitalizeExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension ShortenExtension on String {
  String shorten() {
    try {
      return "${substring(0, 2)}...${substring(length - 5)}";
    } catch (e) {
      return toString();
    }
  }
}

String toShortDisplay(String? value){
  return value!=null?value.shorten():"";
}

String formatAmountToDisplayBigInt(BigInt decimalsVal,
    {int decimals = 18, int fractionDigits = 0}) {
  double value = decimalsVal /
      (BigInt.from(10)
          .pow(decimals > fractionDigits ? decimals - fractionDigits : 0));
  return NumberFormat.compact()
      .format(value /
          (decimals <= fractionDigits || fractionDigits == 0
              ? 1
              : BigInt.from(10).pow(fractionDigits).toDouble()))
      .toString();
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

bool isMainnet(String? genHash){
  return genHash==null?false : Constants.REEF_MAINNET_GENESIS_HASH==genHash.trim();
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

bool isReefAddrPrefix(String address) {
  return address.startsWith('5');
}
