import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/password_manager.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class RestoreJSON extends StatefulWidget {
  const RestoreJSON({super.key});

  @override
  State<RestoreJSON> createState() => _RestoreJSONState();
}

class _RestoreJSONState extends State<RestoreJSON> {
  File? _selectedFile;
  TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isPasswordSet = false;

  final svgData = """
<svg viewBox='0 0 64 64' xmlns='http://www.w3.org/2000/svg'>
  <circle cx='32' cy='32' fill='#eee' r='32' />
  <circle cx='32' cy='8' fill='hsl(45, 40%, 35%)' r='5' />
  <circle cx='32' cy='20' fill='hsl(354, 40%, 35%)' r='5' />
  <circle cx='21.607695154586736' cy='14' fill='hsl(168, 40%, 35%)' r='5' />
  <circle cx='11.215390309173472' cy='20' fill='hsl(106, 40%, 15%)' r='5' />
  <circle cx='21.607695154586736' cy='26' fill='hsl(331, 40%, 15%)' r='5' />
  <circle cx='11.215390309173472' cy='32' fill='hsl(5, 40%, 53%)' r='5' />
  <circle cx='11.215390309173472' cy='44' fill='hsl(45, 40%, 35%)' r='5' />
  <circle cx='21.607695154586736' cy='38' fill='hsl(354, 40%, 35%)' r='5' />
  <circle cx='21.607695154586736' cy='50' fill='hsl(168, 40%, 35%)' r='5' />
  <circle cx='32' cy='56' fill='hsl(106, 40%, 15%)' r='5' />
  <circle cx='32' cy='44' fill='hsl(331, 40%, 15%)' r='5' />
  <circle cx='42.392304845413264' cy='50' fill='hsl(5, 40%, 53%)' r='5' />
  <circle cx='52.78460969082653' cy='44' fill='hsl(45, 40%, 35%)' r='5' />
  <circle cx='42.392304845413264' cy='38' fill='hsl(354, 40%, 35%)' r='5' />
  <circle cx='52.78460969082653' cy='32' fill='hsl(168, 40%, 35%)' r='5' />
  <circle cx='42.392304845413264' cy='26' fill='hsl(106, 40%, 15%)' r='5' />
  <circle cx='52.78460969082653' cy='20' fill='hsl(331, 40%, 15%)' r='5' />
</svg>
""";

  String _fileButtonText = 'Select file';
  bool _isButtonPressed = false;

  @override
  void initState() {
    PasswordManager.checkIfPassword().then((value) => {
          setState(() {
            _isPasswordSet = value;
          })
        });
    super.initState();
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path ?? '');
        _fileButtonText = 'File Selected';
      });
    }
  }

  void _onPressedNext() async {
    setState(() {
      _isButtonPressed = true;
    });
    String password = _passwordController.text;

    if (_selectedFile != null && password.isNotEmpty) {
      try {
        // Read JSON file
        String jsonString = _selectedFile!.readAsStringSync();
        Map<String, dynamic> jsonData = jsonDecode(jsonString);

        // Decrypt data with password
        final response = await ReefAppState.instance.accountCtrl
            .restoreJson(jsonData, password);
        if (response == "error") {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.incorrect_password),
              duration: Duration(seconds: 2),
            ),
          );
        }

        response['svg'] = svgData;
        // while importing from account.json file we won't get mnemonics but we are extracting meaningful info with which we can sign tx : address and pass
        response['mnemonic'] = jsonData["address"] + "+" + password;
        response['name'] = response['meta']['name'];
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
            content: Text('Account Imported Successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print("ENCOUNTERED AN ERROR: $e");
      }
    }
    setState(() {
      _isButtonPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: !_isPasswordSet
          ? [
              ChangePassword(onChanged: () => showRestoreJson(context)),
            ]
          : [
              if (_isButtonPressed)
                Expanded(
                  child: Container(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Styles.primaryAccentColor,
                      ),
                    ),
                  ),
                ),
              if (!_isButtonPressed)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            backgroundColor: const Color(0xff9d6cff),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _selectFile,
                          child: Builder(builder: (context) {
                            return Text(
                              _fileButtonText,
                              style: TextStyle(fontSize: 16.0),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 16),
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
                          decoration: const InputDecoration.collapsed(
                              hintText: 'Password'),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isButtonEnabled =
                                  _selectedFile != null && value.isNotEmpty;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16),
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
                                ? const Color(0xff9d6cff)
                                : Styles.secondaryAccentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isButtonEnabled ? _onPressedNext : null,
                          child: Builder(builder: (context) {
                            return Text(
                              AppLocalizations.of(context)!.import_the_account,
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
                ),
            ],
    );
  }
}

void showRestoreJson(BuildContext? context) {
  showModal(
    context ?? navigatorKey.currentContext,
    child: RestoreJSON(),
    headText: AppLocalizations.of(context!)!.restore_from_json,
  );
}
