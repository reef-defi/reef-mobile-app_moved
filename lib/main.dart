import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/SignatureRequestComponent.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/pages/accounts.dart';

void main() async {
  runApp(
    SplashApp(
      key: UniqueKey(),
      onInitializationComplete: () {
        return const MyHomePage(title: 'Reef demo');
      },
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  void _navigateAccounts() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AccountPage(
              ReefAppState.instance, ReefAppState.instance.storage)),
    );
  }

  void _testSignRaw(address) async {
    const message = "Hello World";
    var signTestRes = await ReefAppState.instance.signingCtrl
        .initSignRawTest(address, message);
    print("SGN RAW TEST=$signTestRes");
  }

  void _testSignPayload(address) async {
    const payload = {
      "specVersion": "0x00000008",
      "transactionVersion": "0x00000002",
      "address": "5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP",
      "blockHash":
          "0xb4c87dc6df4fcf1b5b517e0f44510959770483df63cb24cee56e7826f5340264",
      "blockNumber": "0x003670cd",
      "era": "0xd500",
      "genesisHash":
          "0x0f89efd7bf650f2d521afef7456ed98dff138f54b5b7915cc9bce437ab728660",
      "method":
          "0x15000a3f2785dbbc5f022de511aab8846388b78009fd902e519f9000000000000000000000000000000000000000000000000000000000000000a4000064a7b3b6e00d0000000000000000d430230000000000d0070000",
      "nonce": "0x0000003b",
      "signedExtensions": [
        "CheckSpecVersion",
        "CheckTxVersion",
        "CheckGenesis",
        "CheckMortality",
        "CheckNonce",
        "CheckWeight",
        "ChargeTransactionPayment",
        "SetEvmOrigin"
      ],
      "tip": "0x00000000000000000000000000000000",
      "version": 4
    };
    var signTestRes = await ReefAppState.instance.signingCtrl
        .initSignPayloadTest(address, payload);
    print("SGN PAYLOAD TEST=$signTestRes");
  }

  @override
  Widget build(BuildContext context) {
    var content = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Observer(builder: (_) {
                if (ReefAppState.instance.accountCtrl.account.selectedSigner !=
                    null) {
                  return Text(ReefAppState
                      .instance.accountCtrl.account.selectedSigner!.address);
                }
                return Text('loading signer');
              }),
              Observer(builder: (_) {
                return Column(
                    children: List.from(ReefAppState
                        .instance.tokensCtrl.tokenList.tokens
                        .map((t) => Text('TKN=${t.symbol}'))));
              }),
              TextButton(
                  onPressed: _navigateAccounts, child: const Text('Accounts')),
            ],
          ),
        ),
        floatingActionButton: Observer(builder: (_) {
          if (ReefAppState.instance.accountCtrl.account.selectedSigner !=
              null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: "sign_raw",
                    onPressed: () {
                      _testSignRaw(ReefAppState.instance.accountCtrl.account
                          .selectedSigner?.address);
                    },
                    child: const Text('Sign raw', textAlign: TextAlign.center),
                  ),
                  FloatingActionButton(
                    heroTag: "sign_payload",
                    onPressed: () {
                      _testSignPayload(ReefAppState.instance.accountCtrl.account
                          .selectedSigner?.address);
                    },
                    child:
                        const Text('Sign payload', textAlign: TextAlign.center),
                  )
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }));
    return SignatureOrContentComponent(
        content: content, reefState: ReefAppState.instance);
  }
}
