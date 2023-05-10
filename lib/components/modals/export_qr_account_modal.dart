import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/generateQrJsonValue.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reef_mobile_app/utils/password_manager.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExportQrAccount extends StatefulWidget {
  const ExportQrAccount(@required this.address, {super.key});
  final String address;

  @override
  State<ExportQrAccount> createState() => _ExportQrAccountState();
}

class _ExportQrAccountState extends State<ExportQrAccount> {
  String? data;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _exportPasswordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _exportWithDiffPass = false;
  String errorMessage = "";
  String exportingText = "Exporting with app password";

  void _onPressedNext() async {
    final _storedAccountInstance =
        await ReefAppState.instance.storage.getAccount(widget.address);
    final appPassword = await ReefAppState.instance.storageCtrl
        .getValue(StorageKey.password.name);
    if (!PasswordManager.isJsonImportedAccount(
        _storedAccountInstance.mnemonic)) {
      ReefAppState.instance.accountCtrl
          .accountsCreateSuri(_storedAccountInstance.mnemonic, appPassword);
    }
    setState(() {
      _isLoading = true;
      errorMessage = "";
    });
    String password = _passwordController.text;
    String differentPassword = _exportPasswordController.text;
    if (_exportWithDiffPass && password == appPassword) {
      print("EXPORTING WITH DIFFERENT PASSWORD");
      await ReefAppState.instance.accountCtrl
          .changeAccountPassword(widget.address, differentPassword, password);
    }
    final res = _exportWithDiffPass
        ? await ReefAppState.instance.accountCtrl
            .exportAccountQr(widget.address, differentPassword)
        : await ReefAppState.instance.accountCtrl
            .exportAccountQr(widget.address, password);
    if (res == "error") {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.incorrect_password;
        _isLoading = false;
        _passwordController.text = "";
        _exportPasswordController.text = "";
      });
    } else {
      Map<String, dynamic> response = {};
      response['encoded'] = res['exportedJson']['encoded'];
      response['encoding'] = res['exportedJson']['encoding'];
      response['address'] = res['exportedJson']['address'];
      final resultToSend = jsonEncode(response);
      setState(() {
        data = resultToSend.toString();
        _isLoading = false;
      });
      if (_exportWithDiffPass) {
        await ReefAppState.instance.accountCtrl
            .changeAccountPassword(widget.address, password, differentPassword);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (data != null)
            GenerateQrJsonValue(type: ReefQrCodeType.accountJson, data: data!),
          if (!_isLoading && data == null)
            Column(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.enter_password_for} ${widget.address}",
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.start,
                ),
                Gap(8.0),
                Row(
                  children: [
                    Checkbox(
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor: MaterialStateProperty.all<Color>(
                          Styles.primaryAccentColor),
                      value: _exportWithDiffPass,
                      onChanged: (bool? value) {
                        setState(() {
                          _exportWithDiffPass = value ?? false;
                          exportingText = value!
                              ? AppLocalizations.of(context)!.export_custom_pass
                              : AppLocalizations.of(context)!.export_app_pass;
                          _isButtonEnabled = _passwordController.text.isEmpty ||
                                  (_exportPasswordController.text.isEmpty &&
                                      _exportWithDiffPass)
                              ? false
                              : true;
                        });
                      },
                    ),
                    const Gap(8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.export_diff_pass,
                        style:
                            TextStyle(color: Colors.grey[600]!, fontSize: 14),
                      ),
                    )
                  ],
                ),
                if (_exportWithDiffPass)
                  Column(
                    children: [
                      Gap(8.0),
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
                          controller: _exportPasswordController,
                          obscureText: true,
                          decoration: InputDecoration.collapsed(
                              hintText:
                                  AppLocalizations.of(context)!.export_pass),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isButtonEnabled = (_passwordController
                                          .text.isEmpty ||
                                      (_exportPasswordController.text.isEmpty &&
                                          _exportWithDiffPass))
                                  ? false
                                  : true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                Gap(8.0),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                        hintText: AppLocalizations.of(context)!.password),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isButtonEnabled = _passwordController.text.isEmpty ||
                                (_exportPasswordController.text.isEmpty &&
                                    _exportWithDiffPass)
                            ? false
                            : true;
                      });
                    },
                  ),
                ),
              ],
            ),
          if (_isLoading)
            Center(
                child: Column(children: [
              Text(exportingText),
              Gap(8),
              LinearProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Styles.primaryAccentColor),
                backgroundColor: Styles.greyColor,
              )
            ])),
          if (errorMessage != "")
            Text(
              errorMessage,
              style: TextStyle(fontSize: 12.0, color: Styles.errorColor),
            ),
          SizedBox(height: 16),
          if (data == null)
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
                  backgroundColor: _isButtonEnabled
                      ? Styles.secondaryAccentColor
                      : const Color(0xff9d6cff),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isButtonEnabled ? _onPressedNext : null,
                child: Builder(builder: (context) {
                  return Text(
                    AppLocalizations.of(context)!.export_account,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

void showExportQrAccount(String title, String accountAddress,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ExportQrAccount(accountAddress), headText: title);
}
