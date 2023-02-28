import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import 'modals/signing_modals.dart';

class SignatureContentToggle extends StatelessObserverWidget {
  final Widget content;

  const SignatureContentToggle(this.content, {Key? key}) : super(key: key);

  void _decodeMethod(dynamic request) async {
    dynamic types;
    var metadata = await ReefAppState.instance.storage
        .getMetadata(request.payload.genesisHash);
    if (metadata != null &&
        metadata.specVersion ==
            int.parse(request.payload.specVersion.substring(2), radix: 16)) {
      types = metadata.types;
    }
    var res = await ReefAppState.instance.signingCtrl
        .decodeMethod(request.payload.method, types);

    // TODO also get ABI from contract (res['args'][0]) and decode ethers.decode res['args'][1] EVM arguments - https://app.clickup.com/t/861me3nvy
    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      var requests = ReefAppState.instance.model.signatureRequests.list;
      var signatureRequest = requests.isNotEmpty ? requests.first : null;
      var displayIdx = signatureRequest != null ? 0 : 1;
      // displayIdx = 1; // TODO remove this line
      return IndexedStack(
        index: displayIdx,
        children: [
          Scaffold(
            backgroundColor: Styles.primaryBackgroundColor,
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  AppLocalizations.of(context)!.sign_transaction,
                  style: TextStyle(color: Styles.textColor),
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
                  icon: Icon(
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
                Text(
                  "Transaction Details",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Styles.textColor,
                  ),
                ),
                Gap(10),
                ElevatedButton(
                    onPressed: () {
                      showSigningModal(context, signatureRequest!);
                    },
                    child: Text('display modal')),
                Container(
                  height: 80,
                  width: 250,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment(0, 0.2),
                          end: Alignment(0.1, 1.3),
                          colors: [
                            Color.fromARGB(198, 37, 19, 79),
                            Color.fromARGB(53, 110, 27, 117),
                          ]),
                      border: Border.all(
                          color: Color(Styles.purpleColor.value), width: 0),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${signatureRequest?.signatureIdent}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            shadowColor: const Color(0x559d6cff),
                            elevation: 5,
                            backgroundColor: Styles.primaryAccentColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          onPressed: () => _decodeMethod(signatureRequest),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.crop_free, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.decode,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            shadowColor: const Color(0x559d6cff),
                            elevation: 5,
                            backgroundColor: Styles.primaryAccentColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          onPressed: () => _cancel(signatureRequest),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cancel, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.cancel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Gap(8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 5,
                    backgroundColor: Styles.secondaryAccentColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 56),
                  ),
                  onPressed: () => _confirmSign(signatureRequest),
                  child: Text(
                    "Sign Transaction",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content
        ],
      );
    });
  }

  void _confirmSign(SignatureRequest? signatureRequest) {
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl.confirmSignature(
      signatureRequest.signatureIdent,
      signatureRequest.payload.address,
    );
  }

  void _cancel(SignatureRequest? signatureRequest) {
    print('REMMMMMMMMM $signatureRequest');
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl
        .rejectSignature(signatureRequest.signatureIdent);
  }
}
