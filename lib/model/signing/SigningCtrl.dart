import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class SigningCtrl {

  final SignatureRequests signatureRequests = SignatureRequests();
  final JsApiService jsApi;

  SigningCtrl(JsApiService this.jsApi){

    jsApi.jsTxSignatureConfirmationMessageSubj.listen((value) {
      var sigConfirmationIdent = value.value['signatureIdent'];
      print('TODO display signature confirmation = ${value.value}');
      signatureRequests.add(value.value);

      // jsApi.confirmTxSignature(sigConfirmationIdent, mnemonic);
    });

  }

  confirmSignature(String sigConfirmationIdent) {
    signatureRequests.remove(sigConfirmationIdent);
    var mnemonic = 'test menmonic';
    jsApi.confirmTxSignature(sigConfirmationIdent, mnemonic);
  }
}
