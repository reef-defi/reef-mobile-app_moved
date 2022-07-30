import 'Token.dart';

class TokenWithAmount extends Token {
  final String amount;
  final num price;

  const TokenWithAmount({
    required String name,
    required address,
    required iconUrl,
    required symbol,
    required balance,
    required decimals,
    required this.amount,
    required this.price}):super(name: name, address:address, iconUrl:iconUrl, symbol:symbol, balance:balance, decimals:decimals);

  static fromJSON(dynamic json){
    var tkn = Token.fromJSON(json);
    return TokenWithAmount(name: tkn.name, address: tkn.address, iconUrl: tkn.iconUrl, symbol: tkn.symbol, balance: tkn.balance, decimals: tkn.decimals, amount: json['amount'], price: json['price']);
  }

}
