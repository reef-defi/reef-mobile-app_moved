import '../../utils/JsonBigInt.dart';
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
    var balanceVal = JsonBigInt.toBigInt(json['balance']);
    return TokenWithAmount(name: json['name'], address: json['address'], iconUrl: json['iconUrl'], symbol: json['symbol'], balance: balanceVal, decimals: json['decimals'], amount: json['amount'], price: json['price']);
  }

}
