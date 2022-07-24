import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';

class SignatureContentToggle extends StatelessObserverWidget {
  final Widget content;

  const SignatureContentToggle(this.content,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      var requests = ReefAppState.instance.signingCtrl.signatureRequests.sigRequests;
      var signatureRequest = requests.isNotEmpty ? requests.first : null;
      var displayIdx = signatureRequest != null ? 0 : 1;

      return IndexedStack(
        index: displayIdx,
        children: [
          Scaffold(
              appBar: AppBar(
                title: Text('Sign Transaction'),
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
                    icon: const Icon(Icons.arrow_back ),
                    label: Text('Cancel'),
                    onPressed: () => _cancel(signatureRequest),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.key),
                    label: Text('Sign'),
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
    print("_confirmSign: $signatureRequest");
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl.confirmSignature(
      signatureRequest.signatureIdent,
      signatureRequest.payload.address,
    );
  }
  void _cancel(SignatureRequest? signatureRequest) {
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl.signatureRequests.remove(signatureRequest.signatureIdent);
  }
}
