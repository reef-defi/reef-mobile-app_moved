// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import 'signature_request.dart';

part 'signature_requests.g.dart';

class SignatureRequests = _SignatureRequests with _$SignatureRequests;

abstract class _SignatureRequests with Store {

  @observable
  ObservableList<SignatureRequest> sigRequests = ObservableList<SignatureRequest>();

  @action
  void add(SignatureRequest sigRequest) {
    sigRequests.add(sigRequest);
  }

  @action
  void remove(String sigRequestIdent) {
    sigRequests.removeWhere((sr) {
      return sr.signatureIdent == sigRequestIdent;
    });
  }

}
