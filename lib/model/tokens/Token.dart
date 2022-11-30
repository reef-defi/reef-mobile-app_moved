import '../../utils/json_big_int.dart';

class Token {
  final String name;
  final String address;
  final String? iconUrl;
  final String symbol;
  final BigInt balance;
  final int decimals;

  const Token(
      {required this.name,
      required this.address,
      required this.iconUrl,
      required this.symbol,
      required this.balance,
      required this.decimals});

  static Token fromJson(dynamic json) {
    var balanceVal = JsonBigInt.toBigInt(json['balance']);
    return Token(
        name: json['name'] ?? '<no title>',
        address: json['address'],
        iconUrl: json['iconUrl'] ?? null,
        symbol: json['symbol'] ?? '<no symbol>',
        balance: balanceVal ?? BigInt.zero,
        decimals: json['decimals'] ?? 0);
  }
}
