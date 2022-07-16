import 'package:mobx/mobx.dart';

part 'signer_payload_raw.g.dart';

class SignerPayloadRaw = _SignerPayloadRaw with _$SignerPayloadRaw;

abstract class _SignerPayloadRaw with Store {
  _SignerPayloadRaw(this.address, this.data, this.type);

  @observable
  String address = '';

  @observable
  String data = '';

  @observable
  String type = '';
} 