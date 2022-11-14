import 'package:mobx/mobx.dart';

part 'signer_payload_json.g.dart';

class SignerPayloadJSON = _SignerPayloadJSON with _$SignerPayloadJSON;

abstract class _SignerPayloadJSON with Store {
  _SignerPayloadJSON(
      this.address,
      this.blockHash,
      this.blockNumber,
      this.era,
      this.genesisHash,
      this.method,
      this.nonce,
      this.specVersion,
      this.tip,
      this.transactionVersion,
      this.signedExtensions,
      this.version);

  @observable
  String address = '';

  @observable
  String blockHash = '';

  @observable
  String blockNumber = '';

  @observable
  String era = '';

  @observable
  String genesisHash = '';

  @observable
  String method = '';

  @observable
  String nonce = '';

  @observable
  String specVersion = '';

  @observable
  String tip = '';

  @observable
  String transactionVersion = '';

  @observable
  List<String> signedExtensions = [];

  @observable
  int version = 0;

  String type = "transaction";
}
