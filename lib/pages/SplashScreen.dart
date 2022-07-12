
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';
import '../model/ReefState.dart';
import '../service/JsApiService.dart';
import '../service/StorageService.dart';

class SplashApp extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashApp({
    required Key key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  _SplashAppState createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    print('INIT STATE');
    final jsApiService = JsApiService();
    final storageService = StorageService();
    print('INIT STATE1');
    await ReefState.instance.init(jsApiService, storageService);
    print('INIT STATE2');
    widget.onInitializationComplete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: ElevatedButton(
          child: Text('retry'),
          onPressed: () => main(),
        ),
      );
    }
    /*return Center(
      child: CircularProgressIndicator(),
    );*/
    return Container(
      width: 10.0,
      height: 10.0,
      child: ReefState.instance.jsApi.widget,
    );
  }
}
