import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/model/ReefState.dart';

class SignatureOrContentComponent extends StatelessObserverWidget {
  final Widget content;
  final ReefAppState reefState;

  const SignatureOrContentComponent(
      { Key? key, required this.content, required this.reefState })
      :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      var requests = this.reefState.signingCtrl.signatureRequests.sigRequests;
      var signatureRequest = requests.isNotEmpty?requests.first:null;
      var displayIdx = signatureRequest!=null?0:1;

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
                    'Transaction details...${signatureRequest?['signatureIdent']}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline4,
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _confirmSign(signatureRequest),
              tooltip: 'Sign',
              child: const Icon(Icons.key),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
          content
        ],
      );
    });
  }

  void _confirmSign(dynamic signatureRequest) {
    reefState.signingCtrl.confirmSignature(signatureRequest['signatureIdent']);
  }
}
