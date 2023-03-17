import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
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

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path??"");
        _isButtonEnabled = true;
      });
    }
  }

  void _onPressedNext() async{
    String password = _passwordController.text;

    if (_selectedFile != null && password.isNotEmpty) {
      try {
        // Read JSON file
        String jsonString = _selectedFile!.readAsStringSync();
        Map<String, dynamic> jsonData = jsonDecode(jsonString);

        // Decrypt data with password
        final response = await ReefAppState.instance.accountCtrl.restoreJson(jsonData,password);
        response['svg']=svgData;
        response['mnemonic']="";
        response['name']=response['meta']['name'];
        final importedAccount = StoredAccount.fromString(jsonEncode(response).toString());
        await ReefAppState.instance.accountCtrl.saveAccount(importedAccount);

        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account Imported Successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Show error message
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wrong Password!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Select file'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _isButtonEnabled = _selectedFile != null && value.isNotEmpty;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isButtonEnabled ? _onPressedNext : null,
              child: Text('Import Account'),
            ),
          ],
        )
    );
  }
}

void showRestoreJson(
    BuildContext? context) {
  showModal(context ?? navigatorKey.currentContext,
      child: RestoreJSON(), headText: "Restore from JSON");
}
