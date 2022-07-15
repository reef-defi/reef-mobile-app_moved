import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'signer_payload_json.dart';
import 'signer_payload_raw.dart';

part 'signature_request.g.dart';

class SignatureRequest = _SignatureRequest with _$SignatureRequest;

abstract class _SignatureRequest with Store {
  _SignatureRequest(this.signatureIdent, this.payload);

  @observable
  String signatureIdent = '';

  @observable
  dynamic payload;
}
