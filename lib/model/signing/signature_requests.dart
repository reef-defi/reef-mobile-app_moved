import 'package:mobx/mobx.dart';

part 'signature_requests.g.dart';


class SignatureRequests = _SignatureRequests with _$SignatureRequests;

abstract class _SignatureRequests with Store {

  // TODO replace dynamic with type
  @observable
  ObservableList<dynamic> sigRequests = ObservableList<dynamic>();

  @action
  void add(dynamic sigRequest) {
    this.sigRequests.add(sigRequest);
  }

  @action
  void remove(String sigRequestIdent) {
    this.sigRequests.removeWhere((sr){
      return sr['signatureIdent']==sigRequestIdent;
    });
  }

}
