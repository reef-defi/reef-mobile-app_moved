import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/sign/MethodGeneralDataDisplay.dart';
import 'package:reef_mobile_app/components/sign/SignatureControls.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import 'MethodDataDisplay.dart';
import 'MethodDataLoadingIndicator.dart';

class SignatureContentToggle extends StatelessObserverWidget {
  final Widget content;

  const SignatureContentToggle(
    this.content, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      var requests = ReefAppState.instance.model.signatureRequests.list;
      var signatureRequest = requests.isNotEmpty ? requests.first : null;
      var displayIdx = signatureRequest != null ? 0 : 1;
      var account = signatureRequest != null
          ? ReefAppState.instance.signingCtrl
              .getSignatureSigner(signatureRequest)
          : null;
      // displayIdx = 1; // TODO remove this line
      return IndexedStack(
        index: displayIdx,
        children: [buildSignUI(context, signatureRequest, account), content],
      );
    });
  }

  Scaffold buildSignUI(BuildContext context, SignatureRequest? signatureRequest,
      StatusDataObject<ReefAccount>? account) {
    return Scaffold(
      backgroundColor: Styles.primaryBackgroundColor,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            AppLocalizations.of(context)!.sign_transaction,
            style: const TextStyle(color: Styles.textColor),
          ),
        ),
        leading: IconButton(
          icon: Image.asset('assets/images/reef.png'),
          onPressed: () {
            // TODO: implement menu button action
          },
        ),
        backgroundColor: Styles.primaryBackgroundColor,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Styles.textColor,
            ),
            onPressed: () {
              _cancel(signatureRequest);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            // AppLocalizations.of(context)!.transaction_details,
            'Tx details',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Styles.textColor,
            ),
          ),
          if (account != null)
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AccountBox(
                        reefAccountFDM: account,
                        selected: false,
                        onSelected: () => {},
                        showOptions: false),
                  ],
                )),
          Expanded(
              child: Column(children: [
            MethodDataLoadingIndicator(signatureRequest),
            MethodDataDisplay(signatureRequest),
          ])),
          if (signatureRequest != null)
            SignatureControls(
                signatureRequest,
                (String password) => _confirmSign(signatureRequest, password),
                () => _cancel(signatureRequest))
        ],
      ),
    );
  }

  Future<bool> _confirmSign(
          SignatureRequest signatureRequest, String password) =>
      ReefAppState.instance.signingCtrl
          .authenticateAndSign(signatureRequest, password);

  void _cancel(SignatureRequest? signatureRequest) {
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl
        .rejectSignature(signatureRequest.signatureIdent);
  }
}
