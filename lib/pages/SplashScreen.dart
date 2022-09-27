import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import '../main.dart';
import '../model/ReefAppState.dart';
import '../service/JsApiService.dart';
import '../service/StorageService.dart';

typedef WidgetCallback = Widget Function();

final navigatorKey = GlobalKey<NavigatorState>();

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
  bool _isGifFinished = false;
  Widget? onInitWidget;
  var displayContent = false;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
    Timer(const Duration(milliseconds: 3830), () {
      setState(() {
        _isGifFinished = true;
      });
    });
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
      title: 'Reef Chain App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _buildBody(),
      navigatorKey: navigatorKey,
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

    //TODO: Initialise the widget back
    return Stack(children: <Widget>[
      widget.reefJsApiService.widget,
      displayContent == false
          ? Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Styles.splashBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/intro.gif",
                        height: 128.0,
                        width: 128.0,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCirc,
                    opacity: _isGifFinished ? 1 : 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Loading App",
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Styles.textLightColor,
                              decoration: TextDecoration.none),
                        ),
                        const Gap(4),
                        SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Styles.textLightColor)),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          : widget.displayOnInit(),
    ]);
  }
}
