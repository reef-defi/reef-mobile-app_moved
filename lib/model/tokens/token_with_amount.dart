import 'package:mobx/mobx.dart';

part 'token_with_amount.g.dart';

class TokenWithAmount = _TokenWithAmount with _$TokenWithAmount;

abstract class _TokenWithAmount with Store {
  _TokenWithAmount(this.address, this.amount, this.decimals);

  @observable
  String address = '';

  @observable
  String amount = '';

  @observable
  int decimals = 18;

  Map toJson() => {
    'address': address,
    'amount': amount,
    'decimals': decimals,
  };
}
