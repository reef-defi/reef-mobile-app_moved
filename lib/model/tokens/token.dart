import 'dart:convert';

import 'package:mobx/mobx.dart';

part 'token.g.dart';

class Token = _Token with _$Token;

abstract class _Token with Store {
  _Token(this.name, this.address, this.iconUrl, this.symbol, this.balance,
      this.decimals);

  @observable
  String name = '';

  @observable
  String address = '';

  @observable
  String iconUrl = '';

  @observable
  String symbol = '';

  @observable
  String balance = '';

  @observable
  int decimals = 18;
}

Token tokenFromJson(dynamic jsonObject) {
  return Token(
      jsonObject['name'],
      jsonObject['address'],
      jsonObject['iconUrl'],
      jsonObject['symbol'],
      BigInt.parse(jsonObject['balance']['hex']).toString(),
      jsonObject['decimals']
  );
}

String formatBalance(Token token, {int decimalPlaces = 4}) {
  return (BigInt.parse(token.balance) / BigInt.from(10).pow(token.decimals))
      .toStringAsFixed(decimalPlaces);
}
