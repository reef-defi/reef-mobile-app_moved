class Token {
  final String name;
  final String address;
  final String iconUrl;
  final String symbol;
  final BigInt balance;
  final int decimals;

  const Token({
    required this.name,
    required this.address,
    required this.iconUrl,
    required this.symbol,
    required this.balance,
    required this.decimals});

  static fromJSON(dynamic json){
    return Token(name: json['name'], address: json['address'], iconUrl: json['iconUrl'], symbol: json['symbol'], balance: json['balance'], decimals: json['decimals']);
  }
}
