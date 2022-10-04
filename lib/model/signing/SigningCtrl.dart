import 'dart:convert';

import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_json.dart';
import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_raw.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class SigningCtrl {
  final SignatureRequests signatureRequests;
  final JsApiService jsApi;
  final StorageService storage;

  SigningCtrl(JsApiService this.jsApi, StorageService this.storage,
      SignatureRequests this.signatureRequests) {
    jsApi.jsTxSignatureConfirmationMessageSubj.listen((jsApiMessage) {
      signatureRequests.add(_buildSignatureRequest(jsApiMessage));
    });
  }

  Future<dynamic> signRaw(String address, String message) =>
      jsApi.jsPromise('signApi.signRawPromise(`$address`, `$message`);');

  Future<dynamic> signPayload(String address, Map<String, dynamic> payload) =>
      jsApi.jsPromise(
          'signApi.signPayloadPromise(`$address`, ${jsonEncode(payload)})');

  Future<dynamic> decodeMethod(String data, dynamic types) =>
      jsApi.jsPromise('utils.decodeMethod(`$data`, ${jsonEncode(types)})');

  confirmSignature(String sigConfirmationIdent, String address) async {
    var account = await storage.getAccount(address);
    if (account == null) {
      print("ERROR: confirmSignature - Account not found.");
      return;
    }
    // TODO user feedback
    signatureRequests.remove(sigConfirmationIdent);
    jsApi.confirmTxSignature(sigConfirmationIdent, account.mnemonic);
  }

  _buildSignatureRequest(JsApiMessage jsApiMessage) {
    var signatureIdent = jsApiMessage.reqId;
    var payload;

    if (jsApiMessage.value["data"] != null) {
      payload = SignerPayloadRaw(jsApiMessage.value["address"],
          jsApiMessage.value["data"], jsApiMessage.value["type"]);
    } else {
      payload = SignerPayloadJSON(
          jsApiMessage.value["address"],
          jsApiMessage.value["blockHash"],
          jsApiMessage.value["blockNumber"],
          jsApiMessage.value["era"],
          jsApiMessage.value["genesisHash"],
          jsApiMessage.value["method"],
          jsApiMessage.value["nonce"],
          jsApiMessage.value["specVersion"],
          jsApiMessage.value["tip"],
          jsApiMessage.value["transactionVersion"],
          jsApiMessage.value["signedExtensions"].cast<String>(),
          jsApiMessage.value["version"]);
    }

    return SignatureRequest(signatureIdent, payload);
  }
}
