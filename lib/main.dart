import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/SignatureContentToggle.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/pages/accounts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/page_layout.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/pages/DAppPage.dart';

void main() async {
  runApp(
    SplashApp(
      key: UniqueKey(),
      displayOnInit: () {
        return const BottomNav();
        // return const MyApp();
        // return const TestHomePage();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reef Chain Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(primary: Styles.primaryColor),
      ),
      home: const BottomNav(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({Key? key}) : super(key: key);

  final String title = "Reef Mobile App";

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  _TestHomePageState();

  void _navigateAccounts() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AccountPage(
              ReefAppState.instance, ReefAppState.instance.storage)),
    );
  }

  void _navigateTestDApp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DAppPage(ReefAppState.instance)),
    );
  }

  void _testSignRaw(address) async {
    const message = "Hello World";
    var signTestRes = await ReefAppState.instance.signingCtrl
        .initSignRawTest(address, message);
    print("SGN RAW TEST=$signTestRes");
  }

  void _testSignPayload(address) async {
    // Sqwid auction transaction
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

  void _testSignAndSend(address) async {
    var txTestRes =
        await ReefAppState.instance.signingCtrl.initSignAndSendTxTest(address);
    print("MAIN TX TEST=$txTestRes");
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
                if (ReefAppState.instance.model.accounts.loadingSigners ==
                    true) {
                  return Text('loading signers');
                }
                if (ReefAppState.instance.model.accounts.signers.length > 0) {
                  return Text(
                      'signers loaded = ${ReefAppState.instance.model.accounts.signers.map((ReefSigner s) {
                    return s.address +
                        ' bal = ' +
                        toBalanceDisplayString(s.balance.toString());
                  }).join('/////')}');
                }
                return Text('no signers found');
              }),
              Observer(builder: (_) {
                return Column(
                    children: List.from(ReefAppState
                        .instance.model.tokens.selectedSignerTokens
                        .map((t) => Text('TKN=${t.symbol}'))));
              }),
              TextButton(
                  onPressed: _navigateAccounts, child: const Text('Accounts')),
              TextButton(
                  onPressed: _navigateTestDApp, child: const Text('DApp')),
            ],
          ),
        ),
        floatingActionButton: Observer(builder: (_) {
          if (ReefAppState.instance.model.accounts.selectedAddress != null) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: "sign_raw",
                    onPressed: () {
                      _testSignRaw(ReefAppState
                          .instance.model.accounts.selectedAddress);
                    },
                    child: const Text('Sign raw', textAlign: TextAlign.center),
                  ),
                  FloatingActionButton(
                    heroTag: "sign_payload",
                    onPressed: () {
                      _testSignPayload(ReefAppState
                          .instance.model.accounts.selectedAddress);
                    },
                    child:
                        const Text('Sign payload', textAlign: TextAlign.center),
                  ),
                  FloatingActionButton(
                    heroTag: "sign_and_send",
                    onPressed: () {
                      _testSignAndSend(ReefAppState
                          .instance.model.accounts.selectedAddress);
                    },
                    child: const Text('Sign and send',
                        textAlign: TextAlign.center),
                  )
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }));
    return SignatureContentToggle(content);
  }
}
