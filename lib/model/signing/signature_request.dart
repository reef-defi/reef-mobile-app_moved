import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'signature_request_value.dart';

part 'signature_request.g.dart';

class SignatureRequest = _SignatureRequest with _$SignatureRequest;

abstract class _SignatureRequest with Store {
  _SignatureRequest(this.signatureIdent, this.value);

  @observable
  String signatureIdent = '';

  @observable
  SignatureRequestValue value = SignatureRequestValue('', '', '');
}