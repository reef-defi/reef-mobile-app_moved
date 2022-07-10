
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/model/ReefState.dart';

class SignatureOrContentComponent extends StatelessObserverWidget {
  final Widget content;
  final ReefState reefState;

  const SignatureOrContentComponent({ Key? key, required this.content, required this.reefState  }):super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (this.reefState.signingCtrl.signatureRequests.sigRequests.isNotEmpty) {
        var signatureRequest = this.reefState.signingCtrl.signatureRequests.sigRequests.first;

        return Scaffold(
          appBar: AppBar(
            title: Text('Sign Transaction'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Transaction details...${signatureRequest['signatureIdent']}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: ()=>_confirmSign(signatureRequest),
            tooltip: 'Sign',
            child: const Icon(Icons.key),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      }
      return content;
    });
  }

  void _confirmSign(dynamic signatureRequest) {
    reefState.signingCtrl.confirmSignature(signatureRequest['signatureIdent']);
  }
}
