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
      displayOnInit: (){return const MyHomePage(title: 'Reef demo');},
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
  int _counter = 0;

  _MyHomePageState() {
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
        var signTestRes = await ReefAppState.instance.signingCtrl.initSignTest(address);
        print("SGN TEST=$signTestRes");
      }();
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var content = Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Container(
              width: 100.0,
              height: 100.0,
              child: jsApiService.widget,
            ),*/
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
                onPressed: _navigateAccounts, child: const Text('Accounts')),
          ],
        ),
      ),
      floatingActionButton: Observer(builder:(_) {
        if (ReefAppState.instance.accountCtrl.account.selectedSigner != null) {
          return FloatingActionButton(
            heroTag: "signBtn1",
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
