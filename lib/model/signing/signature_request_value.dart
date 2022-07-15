import 'package:mobx/mobx.dart';

part 'signature_request_value.g.dart';

class SignatureRequestValue = _SignatureRequestValue with _$SignatureRequestValue;

abstract class _SignatureRequestValue with Store {
  _SignatureRequestValue(this.address, this.data, this.type);

  @observable
  String address = '';

  @observable
  String data = '';

  @observable
  String type = '';
} 