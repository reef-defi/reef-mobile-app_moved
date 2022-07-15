
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../components/JsApiServiceContentWrapper.dart';
import '../main.dart';
import '../model/ReefState.dart';
import '../service/JsApiService.dart';
import '../service/StorageService.dart';

class SplashApp extends StatefulWidget {
  final VoidCallback onInitializationComplete;
  final reefAppJsApiService = JsApiService.reefAppJsApi();

  SplashApp({
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
    final storageService = StorageService();
    await ReefAppState.instance.init(widget.reefAppJsApiService, storageService);
    widget.onInitializationComplete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Setting up Reef Chain App',
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
    // return ReefJsApiWrapper(jsApiService: reefAppJsApiService, content: Center(child: CircularProgressIndicator()));
    return Stack(children: <Widget>[
      widget.reefAppJsApiService.widget,
      Center(child: CircularProgressIndicator()),
    ]);
  }
}
