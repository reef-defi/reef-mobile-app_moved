import 'dart:convert';

import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/signature_request_value.dart';
import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

class SigningCtrl {
  final SignatureRequests signatureRequests = SignatureRequests();
  final JsApiService jsApi;
  final StorageService storage;

  SigningCtrl(JsApiService this.jsApi, StorageService this.storage) {
    jsApi.jsTxSignatureConfirmationMessageSubj.listen((value) {
      // var sigConfirmationIdent = value.value['signatureIdent'];
      signatureRequests.add(value.value);
    });
  }

  Future<dynamic> initSignTest(String address, String message) async {
    return jsApi
        .jsPromise('jsApi.testReefSignerPromise("$address","$message")');
  }

  confirmSignature(String sigConfirmationIdent, String evmAddress) async {
    jsApi.jsObservable('account.availableSigners\$').listen((signers) async {
      var signer =
          signers.firstWhere((signer) => signer['evmAddress'] == evmAddress);
      if (signer == null) {
        print("ERROR: confirmSignature - Signer not found.");
        return;
      }

      var account = await storage.getAccount(signer['address']);
      if (account == null) {
        print("ERROR: confirmSignature - Account not found.");
        return;
      }

      signatureRequests.remove(sigConfirmationIdent);
      jsApi.confirmTxSignature(sigConfirmationIdent, account.mnemonic);
    });
  }
}
