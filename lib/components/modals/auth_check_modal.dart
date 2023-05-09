import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);
  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isAuthenticated = false;
  bool _wrongPassword = false;
  bool _biometricsIsAvailable = false;

  final TextEditingController _passwordController = TextEditingController();
  String password = "";
  static final LocalAuthentication localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      setState(() {
        password = _passwordController.text;
      });
    });
    _checkBiometricsSupport().then((value) {
      setState(() {
        _biometricsIsAvailable = value;
      });
      if (value) {
        authenticateWithBiometrics();
      }
    });
  }

  Future<bool> _checkBiometricsSupport() async {
    final isDeviceSupported = await localAuth.isDeviceSupported();
    final isAvailable = await localAuth.canCheckBiometrics;
    return isAvailable && isDeviceSupported;
  }

  Future<void> authenticateWithPassword(String value) async {
    final storedPassword = await ReefAppState.instance.storageCtrl
        .getValue(StorageKey.password.name);
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
    final isAvailable = await _checkBiometricsSupport();
    if (isAvailable) {
      final isValid = await localAuth.authenticate(
          localizedReason:
              AppLocalizations.of(context)!.authenticate_with_biometrics,
          options: const AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true, biometricOnly: true));
      if (isValid) {
        setState(() {
          _wrongPassword = false;
          _isAuthenticated = true;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 0, left: 24, bottom: 36, right: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.password_for_reef_app,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Styles.textLightColor),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
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
                        Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          color: Styles.errorColor,
                          size: 16,
                        ),
                        const Gap(8),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.incorrect_password,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
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
                            child: Text(
                              AppLocalizations.of(context)!.send,
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
          )
        ]));
  }
}

void showAuthConfirmation(String title, {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: const AuthCheck(), headText: title);
}
