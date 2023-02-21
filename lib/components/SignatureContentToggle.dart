import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      // var requests = ReefAppState.instance.signingCtrl.signatureRequests.list;
      var requests = ReefAppState.instance.model.signatureRequests.list;
      var signatureRequest = requests.isNotEmpty ? requests.first : null;
      var displayIdx = signatureRequest != null ? 0 : 1;
      displayIdx = 1; // TODO remove this line

      return IndexedStack(
        index: displayIdx,
        children: [
          Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.sign_transaction),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Transaction details...${signatureRequest?.signatureIdent}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ),
              floatingActionButton: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(AppLocalizations.of(context)!.decode),
                    onPressed: () => _decodeMethod(signatureRequest),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () => _cancel(signatureRequest),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.key),
                    label: Text(AppLocalizations.of(context)!.to_create_account),
                    onPressed: () => _confirmSign(signatureRequest),
                  ),
                ],
              )),
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
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl.signatureRequests
        .remove(signatureRequest.signatureIdent);
  }
}
