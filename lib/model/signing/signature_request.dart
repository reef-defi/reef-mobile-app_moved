import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/SigningCtrl.dart';
import 'signer_payload_json.dart';
import 'signer_payload_raw.dart';

part 'signature_request.g.dart';

class SignatureRequest = _SignatureRequest with _$SignatureRequest;

abstract class _SignatureRequest with Store {
  SigningCtrl _signingCtrl;

  _SignatureRequest(this.signatureIdent, this.payload, this._signingCtrl);

  @observable
  String signatureIdent = '';

  @observable
  dynamic payload;

  dynamic bytesData;

  // No need to observe this as we are relying on the fetchMethodDataFuture.status
  dynamic decodedMethod;

  @observable
  dynamic txDecodedData;

  static ObservableFuture<dynamic> emptyResponse =
      ObservableFuture.value({});

  @computed
  bool get hasResults =>
      fetchMethodDataFuture != emptyResponse &&
      fetchMethodDataFuture.status == FutureStatus.fulfilled;

  @observable
  ObservableFuture<dynamic> fetchMethodDataFuture = emptyResponse;

  @action
  Future<dynamic> decodeMethod() async {
    decodedMethod = {};
    final future = _signingCtrl.decodeMethod(payload.method);
    fetchMethodDataFuture = ObservableFuture(future);

    decodedMethod = await future;
    txDecodedData = await _signingCtrl.getTxDecodedData(payload, decodedMethod);
    if(toSignatureRequest().payload.type == "bytes"){
    bytesData = await _signingCtrl.bytesString(toSignatureRequest().payload.data);
    }
    return decodedMethod;
  }

  SignatureRequest toSignatureRequest() {
    return SignatureRequest(
      signatureIdent,
      payload,
      _signingCtrl,
    );
  }
}
