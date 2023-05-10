import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/password_manager.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/utils/account_profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const svgData = AccountProfile.iconSvg;

class ImportAccountQr extends StatefulWidget {
  ImportAccountQr({Key? key, this.data}) : super(key: key);
  ReefQrCode? data;
  @override
  State<ImportAccountQr> createState() => _ImportAccountQrState();
}

class _ImportAccountQrState extends State<ImportAccountQr> {
  final GlobalKey _gLobalkey = GlobalKey();
  ReefQrCode? qrCode;
  bool isLoading = false;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  void _onPressedNext() async {
    setState(() {
      isLoading = true;
    });
    final response = await ReefAppState.instance.accountCtrl
        .restoreJson(json.decode(qrCode!.data), _passwordController.text);
    if (response == "error") {
      Navigator.of(context).pop();
      showAlertModal(AppLocalizations.of(context)!.incorrect_password, [
        AppLocalizations.of(context)!.the_pass_is_incorrect,
        AppLocalizations.of(context)!.enter_same_pass
      ]);
    } else {
      response['svg'] = svgData;
      response['mnemonic'] =
          json.decode(qrCode!.data)["address"] + "+" + _passwordController.text;
      response['name'] = _nameController.text.trim();
      final importedAccount =
          StoredAccount.fromString(jsonEncode(response).toString());
      await ReefAppState.instance.accountCtrl.saveAccount(importedAccount);

      //update the password in this stored instance and for account json in backend
      PasswordManager.updateAccountPassword(
          importedAccount,
          await ReefAppState.instance.storageCtrl
              .getValue(StorageKey.password.name));

      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.account_imported_successfully),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    qrCode = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLoading)
              Column(
                children: [
                  if (qrCode != null)
                    Column(
                      children: [
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
                            controller: _nameController,
                            decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.of(context)!
                                    .name_your_account),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        Gap(16),
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
                            decoration: InputDecoration.collapsed(
                                hintText:
                                    AppLocalizations.of(context)!.password),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        Gap(16.0),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              shadowColor: const Color(0x559d6cff),
                              elevation: 5,
                              backgroundColor:
                                  _passwordController.text.isEmpty &&
                                          _nameController.text.isEmpty
                                      ? Styles.secondaryAccentColor
                                      : const Color(0xff9d6cff),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _passwordController.text.isEmpty &&
                                    _nameController.text.isEmpty
                                ? _onPressedNext
                                : null,
                            child: Builder(builder: (context) {
                              return Text(
                                AppLocalizations.of(context)!
                                    .import_the_account,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            if (isLoading)
              CircularProgressIndicator(
                color: Styles.primaryAccentColor,
              ),
          ],
        ));
  }
}

void showImportAccountQrModal({BuildContext? context, ReefQrCode? data}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ImportAccountQr(data: data), headText: "Import the Account");
}
