import 'dart:convert';

import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_json.dart';
import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_raw.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class SigningCtrl {
  final SignatureRequests signatureRequests = SignatureRequests();
  final JsApiService jsApi;
  final StorageService storage;

  SigningCtrl(JsApiService this.jsApi, StorageService this.storage) {
    jsApi.jsTxSignatureConfirmationMessageSubj.listen((jsApiMessage) {
      signatureRequests.add(buildSignatureRequest(jsApiMessage));
    });
  }

  Future<dynamic> initSignRawTest(String address, String message) async {
    return jsApi
        .jsPromise('jsApi.testReefSignerRawPromise("$address","$message")');
  }

  Future<dynamic> initSignPayloadTest(String address, Map<String, Object> payload) async {
    return jsApi
        .jsPromise('jsApi.testReefSignerPayloadPromise("$address", ${jsonEncode(payload)})');
  }

  Future<dynamic> initSignAndSendTxTest(String address) async {
    return jsApi
        .jsPromise('jsApi.testReefSignAndSendTxPromise("$address")');
  }
  
  confirmSignature(String sigConfirmationIdent, String address) async {
    jsApi.jsObservable('account.availableSigners\$').listen((signers) async {
      var account = await storage.getAccount(address);
      if (account == null) {
        print("ERROR: confirmSignature - Account not found.");
        return;
      }
      // TODO user feedback
      signatureRequests.remove(sigConfirmationIdent);
      jsApi.confirmTxSignature(sigConfirmationIdent, account.mnemonic);
    });
  }

  buildSignatureRequest(JsApiMessage jsApiMessage) {
    var signatureIdent = jsApiMessage.value["signatureIdent"];
    var payload;

    if (jsApiMessage.value["value"]["data"] != null) {
      payload = SignerPayloadRaw(
        jsApiMessage.value["value"]["address"],
        jsApiMessage.value["value"]["data"],
        jsApiMessage.value["value"]["type"]
      );
    } else {
      payload = SignerPayloadJSON(
        jsApiMessage.value["value"]["address"],
        jsApiMessage.value["value"]["blockHash"],
        jsApiMessage.value["value"]["blockNumber"],
        jsApiMessage.value["value"]["era"],
        jsApiMessage.value["value"]["genesisHash"],
        jsApiMessage.value["value"]["method"],
        jsApiMessage.value["value"]["nonce"],
        jsApiMessage.value["value"]["specVersion"],
        jsApiMessage.value["value"]["tip"],
        jsApiMessage.value["value"]["transactionVersion"],
        jsApiMessage.value["value"]["signedExtensions"].cast<String>(),
        jsApiMessage.value["value"]["version"]
      );
    }

    return SignatureRequest(signatureIdent, payload);
  }
}
