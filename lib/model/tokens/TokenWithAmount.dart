class TokenWithAmount {
  final String name;
  final String address;
  final String iconUrl;
  final String symbol;
  final String balance;
  final int decimals;
  final String amount;
  final num price;

  const TokenWithAmount({
    required this.name,
    required this.address,
    required this.iconUrl,
    required this.symbol,
    required this.balance,
    required this.decimals,
    required this.amount,
    required this.price});

  static fromJSON(dynamic json){
    return TokenWithAmount(name: json['name'], address: json['address'], iconUrl: json['iconUrl'], symbol: json['symbol'], balance: json['balance'], decimals: json['decimals'], amount: json['amount'], price: json['price']);
  }
}