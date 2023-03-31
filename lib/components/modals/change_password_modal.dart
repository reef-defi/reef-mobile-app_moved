import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  String currPassword = "";
  String confirmCurrPassword = "";
  String newPassword = "";
  String confirmNewPassword = "";

  bool hasPassword = false;
  bool confirmCurrPasswordError = false;
  bool newPasswordError = false;
  bool confirmNewPasswordError = false;

  @override
  void initState() {
    super.initState();

    currPasswordController.addListener(() {
      if (confirmCurrPassword == currPasswordController.text) return;
      setState(() {
        confirmCurrPassword = currPasswordController.text;
        confirmCurrPasswordError = currPassword != confirmCurrPassword;
      });
    });

    newPasswordController.addListener(() {
      if (newPassword == newPasswordController.text) return;
      setState(() {
        newPassword = newPasswordController.text;
        newPasswordError = newPassword.length < 6;
      });
    });

    confirmNewPasswordController.addListener(() {
      if (confirmNewPassword == confirmNewPasswordController.text) return;
      setState(() {
        confirmNewPassword = confirmNewPasswordController.text;
        confirmNewPasswordError = newPassword != confirmNewPassword;
      });
    });

    ReefAppState.instance.storageCtrl
        .getValue(StorageKey.password.name)
        .then((value) => setState(() {
              hasPassword = value != null && value.isNotEmpty;
              if (hasPassword) currPassword = value;
            }));
  }

  @override
  void dispose() {
    super.dispose();
    currPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 0, left: 24, bottom: 36, right: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (hasPassword) ...[
            Text(
              AppLocalizations.of(context)!.change_password_current_password,
              style: const TextStyle(
                  fontSize: 10,
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
                  color: confirmCurrPasswordError
                      ? Styles.errorColor
                      : const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: currPasswordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(8),
            if (confirmCurrPasswordError) ...[
              const Gap(8),
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
                      AppLocalizations.of(context)!
                          .change_password_password_incorrect,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (!hasPassword ||
              (confirmCurrPassword.isNotEmpty &&
                  !confirmCurrPasswordError)) ...[
            const Gap(12),
            Builder(builder: (context) {
              return Text(
                AppLocalizations.of(context)!.new_password,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Styles.textLightColor),
              );
            }),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: newPasswordError
                      ? Styles.errorColor
                      : const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            if (newPasswordError) ...[
              const Gap(8),
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
                      AppLocalizations.of(context)!.password_too_short,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
            if (newPassword.isNotEmpty && !newPasswordError) ...[
              const Gap(16),
              Text(
                AppLocalizations.of(context)!.repetitive_password,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Styles.textLightColor),
              ),
              const Gap(8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Styles.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: confirmNewPasswordError
                        ? Styles.errorColor
                        : const Color(0x20000000),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              if (confirmNewPasswordError) ...[
                const Gap(8),
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
                        AppLocalizations.of(context)!.password_do_not_match,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const Gap(30),
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
                        splashFactory: (confirmNewPassword.isNotEmpty &&
                                !confirmNewPasswordError)
                            ? NoSplash.splashFactory
                            : InkSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        shadowColor: const Color(0x559d6cff),
                        elevation: 5,
                        backgroundColor: (confirmNewPassword.isNotEmpty &&
                                !confirmNewPasswordError)
                            ? Styles.secondaryAccentColor
                            : const Color(0xff9d6cff),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (confirmNewPassword.isNotEmpty &&
                            !confirmNewPasswordError) {
                          ReefAppState.instance.storageCtrl
                              .setValue(StorageKey.password.name, newPassword);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Builder(builder: (context) {
                        return Text(
                          AppLocalizations.of(context)!.change_password,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ]));
  }
}

void showChangePasswordModal(String title, {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: const ChangePassword(), headText: title);
}
