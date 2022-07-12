import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/SignatureRequestComponent.dart';
import 'package:reef_mobile_app/components/WebViewContentWrapper.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/pages/accounts.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

void main() async {
  runApp(
    SplashApp(
      key: UniqueKey(),
      onInitializationComplete: runMainApp,
    ),
  );
}

void runMainApp() {
  print('RUN MAINNNNN');
  runApp(
    MyApp(),
  );
}
/*

void main() async {
  runApp(const MyApp());
}
*/

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // late ReefState reefState;

  _MyHomePageState() {
    // reefState = ReefState(jsApiService, storageService);

  }

  void _navigateAccounts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountPage(ReefState.instance.jsApi, ReefState.instance.storage)),
    );
  }

  void _testTransactionSign(address) async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      ()async{
        var signTestRes = await ReefState.instance.jsApi.jsPromise('jsApi.testReefSignerPromise("$address")');
        print("SGN TEST=$signTestRes");
      }();
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              if (ReefState.instance.accountCtrl.account.selectedSigner != null) {
                return Text(
                    ReefState.instance.accountCtrl.account.selectedSigner!.address);
              }
              return Text('loading signer');
            }),
            Observer(builder: (_) {
              return Column(
                  children: List.from(ReefState.instance.tokensCtrl.tokenList.tokens
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
        if (ReefState.instance.accountCtrl.account.selectedSigner != null) {
          return FloatingActionButton(
            onPressed: () {
              _testTransactionSign(
                  ReefState.instance.accountCtrl.account.selectedSigner?.address);
            },
            tooltip: 'Sign',
            child: const Text('sign test'),
          );
        }
        return SizedBox.shrink();
      })
    );
    return SignatureOrContentComponent(
        content:JsApiServiceContentWrapper(content: content, jsApiService: ReefState.instance.jsApi),
        reefState: ReefState.instance);
  }
}
