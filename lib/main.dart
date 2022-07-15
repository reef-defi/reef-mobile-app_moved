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
      onInitializationComplete: runMainApp,
    ),
  );
}

void runMainApp() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reef Chain Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Reef demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late ReefState reefState;

  _MyHomePageState() {
    // reefState = ReefState(jsApiService, storageService);

  }

  void _navigateAccounts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountPage(ReefAppState.instance, ReefAppState.instance.storage)),
    );
  }

  void _testTransactionSign(address) async {
    setState(() {
      ()async{
        var signTestRes = await ReefAppState.instance.signingCtrl.initSignTest(address, "Hello World");
        print("SGN TEST=$signTestRes");
      }();
    });
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
              if (ReefAppState.instance.accountCtrl.account.selectedSigner != null) {
                return Text(
                    ReefAppState.instance.accountCtrl.account.selectedSigner!.address);
              }
              return Text('loading signer');
            }),
            Observer(builder: (_) {
              return Column(
                  children: List.from(ReefAppState.instance.tokensCtrl.tokenList.tokens
                      .map((t) => Text('TKN=${t.symbol}'))));
            }),
            TextButton(
                onPressed: _navigateAccounts, child: const Text('Accounts')),
          ],
        ),
      ),
      floatingActionButton: Observer(builder:(_) {
        if (ReefAppState.instance.accountCtrl.account.selectedSigner != null) {
          return FloatingActionButton(
            heroTag: null,
            onPressed: () {
              _testTransactionSign(
                  ReefAppState.instance.accountCtrl.account.selectedSigner?.address);
            },
            tooltip: 'Sign',
            child: const Text('sign test'),
          );
        }
        return SizedBox.shrink();
      })
    );
    return SignatureOrContentComponent(
        content:content,
        reefState: ReefAppState.instance);
  }
}
