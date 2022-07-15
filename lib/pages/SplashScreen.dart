
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';
import '../model/ReefState.dart';
import '../service/JsApiService.dart';
import '../service/StorageService.dart';

typedef WidgetCallback = Widget Function();

class SplashApp extends StatefulWidget {
  final JsApiService reefJsApiService = JsApiService.reefAppJsApi();
  WidgetCallback displayOnInit;

  SplashApp({
    required Key key,
    required this.displayOnInit,
  }) : super(key: key);

  @override
  _SplashAppState createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _hasError = false;
  Widget? onInitWidget;
  var displayContent=false;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    final storageService = StorageService();
    await ReefAppState.instance.init(widget.reefJsApiService, storageService);
      setState(() {
        displayContent = true;
      });
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

    return Stack(children: <Widget>[
      widget.reefJsApiService.widget,
      displayContent==false?Center(child: CircularProgressIndicator()):widget.displayOnInit(),
    ]);
  }
}
