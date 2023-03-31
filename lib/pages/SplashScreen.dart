import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reef_mobile_app/components/introduction_page/hero_video.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/locale/LocaleCtrl.dart';
import 'package:reef_mobile_app/model/locale/locale_model.dart';
import 'package:reef_mobile_app/pages/introduction_page.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../model/ReefAppState.dart';
import '../service/JsApiService.dart';
import '../service/StorageService.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef WidgetCallback = Widget Function();

final navigatorKey = GlobalKey<NavigatorState>();

class SplashApp extends StatefulWidget {
  final JsApiService reefJsApiService = JsApiService.reefAppJsApi();
  WidgetCallback displayOnInit;
  final Widget heroVideo = const HeroVideo();

  SplashApp({
    required Key key,
    required this.displayOnInit,
  }) : super(key: key);

  @override
  _SplashAppState createState() => _SplashAppState();

  static void setLocale(BuildContext context, String newLocale) {
    print(
        'setting locale to ===================================== ${newLocale}');
    _SplashAppState? state = context.findAncestorStateOfType<_SplashAppState>();
    state?.setLocale(newLocale);
  }
}

class _SplashAppState extends State<SplashApp> {
  String _locale = ReefAppState.instance.model.locale.selectedLanguage;

  setLocale(String locale) {
    setState(() {
      _locale = locale;
    });
  }

  static const _firstLaunch = "firstLaunch";
  bool _hasError = false;
  bool _isGifFinished = false;
  bool _requiresAuth = false;
  bool _isAuthenticated = false;
  bool _wrongPassword = false;
  bool _biometricsIsAvailable = false;
  bool? _isFirstLaunch;
  Widget? onInitWidget;

  var loaded = false;
  final TextEditingController _passwordController = TextEditingController();
  String password = "";
  static final LocalAuthentication localAuth = LocalAuthentication();

  Future<bool> _checkBiometricsSupport() async {
  final isDeviceSupported = await localAuth.isDeviceSupported();
  final isAvailable = await localAuth.canCheckBiometrics;
  //if it is true - user has registered for bio metrics else didn't
  final isEnrolled = await localAuth.getAvailableBiometrics().then((value) => value.isNotEmpty);
  //if biometrics are not enrolled this bool exp will return false
  return isAvailable && isDeviceSupported && isEnrolled;
}

  Future<bool> _checkRequiresAuth() async {
    final storedPassword =
        await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    return storedPassword != null && storedPassword != "";
  }

  Future<String> getLocale() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString("languageCode") ?? 'en';
    return languageCode;
  }

  @override
  void initState() {
    super.initState();
    getLocale().then((value) => setLocale(value));

    _initializeAsyncDependencies();
    _checkIfFirstLaunch().then((value) {
      setState(() {
        _isFirstLaunch = value;
      });
    });
    Timer(const Duration(milliseconds: 3830), () {
      setState(() {
        _isGifFinished = true;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        password = _passwordController.text;
      });
    });
    if (kDebugMode) {
      setState(() {
        _requiresAuth = false;
        _isAuthenticated = true;
      });
      return;
    }
    _checkRequiresAuth().then((value) {
      setState(() {
        _requiresAuth = value;
        _isAuthenticated = !value;
      });
    });
    _checkBiometricsSupport().then((value) {
      if (value) authenticateWithBiometrics();
      setState(() {
        _biometricsIsAvailable = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  Future<bool> _checkIfFirstLaunch() async {
    final isFirstLaunch =
        await ReefAppState.instance.storage.getValue(_firstLaunch);
    return isFirstLaunch == null;
  }

  Future<void> _initializeAsyncDependencies() async {
    final storageService = StorageService();
    await ReefAppState.instance.init(widget.reefJsApiService, storageService);
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reef Chain App',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(_locale),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      home: _buildBody(),
      navigatorKey: navigatorKey,
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: ElevatedButton(
          child: const Text('retry'),
          onPressed: () => main(),
        ),
      );
    }
    //TODO: Initialise the widget back

    return Stack(children: <Widget>[
      widget.reefJsApiService.widget,
      if ((loaded == false || _isAuthenticated == false) ||
          _isFirstLaunch == null)
        Stack(
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
                  const Gap(16),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _requiresAuth && !_isAuthenticated,
                    child: _buildAuth(),
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
                opacity: _isGifFinished && _isAuthenticated ? 1 : 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Loading App",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Styles.textLightColor,
                          decoration: TextDecoration.none),
                    ),
                    const Gap(4),
                    const SizedBox(
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
      else if (_isFirstLaunch == true &&
          loaded == true &&
          _isAuthenticated == true)
        IntroductionPage(
          heroVideo: widget.heroVideo,
          onDone: () async {
            await ReefAppState.instance.storage.setValue(_firstLaunch, false);
            setState(() {
              _isFirstLaunch = false;
            });
          },
        )
      else
        widget.displayOnInit(),
    ]);
  }

  Future<void> authenticateWithPassword(String value) async {
    final storedPassword =
        await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    if (storedPassword == value) {
      setState(() {
        _wrongPassword = false;
        _isAuthenticated = true;
      });
    } else {
      setState(() {
        _wrongPassword = true;
      });
    }
  }

  Future<void> authenticateWithBiometrics() async {
    final isValid = await localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics',
        options: const AuthenticationOptions(
            useErrorDialogs: true, stickyAuth: true, biometricOnly: true));
    if (isValid) {
      setState(() {
        _wrongPassword = false;
        _isAuthenticated = true;
      });
    }
  }

  Widget _buildAuth() {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PASSWORD FOR REEF APP",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Styles.textLightColor),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(8),
            if (_wrongPassword)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Styles.errorColor,
                    size: 16,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      "Password is incorrect",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            const Gap(12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        splashFactory: !(password.isNotEmpty)
                            ? NoSplash.splashFactory
                            : InkSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        shadowColor: const Color(0x559d6cff),
                        elevation: 5,
                        backgroundColor: (password.isNotEmpty)
                            ? Styles.secondaryAccentColor
                            : const Color(0xff9d6cff),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (password.isNotEmpty) {
                          authenticateWithPassword(password);
                        }
                      },
                      child: const Text(
                        'Send',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(36),
            Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: _biometricsIsAvailable,
                child: Center(
                    child: MaterialButton(
                  minWidth: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: authenticateWithBiometrics,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0.0),
                  child: Ink(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black87,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Styles.primaryAccentColor,
                          Styles.secondaryAccentColor,
                        ],
                      ),
                    ),
                    child: Icon(Icons.fingerprint,
                        size: 36, color: Styles.whiteColor),
                  ),
                ))),
          ],
        ),
      ),
    );
  }
}
