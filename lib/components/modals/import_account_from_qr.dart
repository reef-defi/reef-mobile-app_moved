import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/utils/account_profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const svgData = AccountProfile.iconSvg;

class ImportAccountQr extends StatefulWidget {
  ImportAccountQr({Key? key,this.data}) : super(key: key);
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
  
  void _onPressedNext()async{
    setState(() {
      isLoading = true;
    });
         final response = await ReefAppState.instance.accountCtrl.restoreJson(json.decode(qrCode!.data),_passwordController.text);
        if(response=="error"){
        Navigator.of(context).pop();
        showAlertModal("Invalid QR Code", ["This is an invalid QR code!","You can know more about this QR code from the 'Scan QR' option in Settings "]);
        }else{
        response['svg']=svgData;
        response['mnemonic']="";
        response['name']=_nameController.text.trim();
        final importedAccount = StoredAccount.fromString(jsonEncode(response).toString());
        await ReefAppState.instance.accountCtrl.saveAccount(importedAccount);
        Navigator.pop(context);
        }
  }

  @override
  void initState(){
    qrCode = widget.data;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(!isLoading)
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  if(qrCode!=null)
                   Column(
                     children: [
                       Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Styles.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                        color:  const Color(0x20000000),
                        width: 1,
                  ),
                ),
                child:  TextField(
                controller: _nameController,
                decoration: const InputDecoration.collapsed(hintText: 'Name your account'),
                  style: const TextStyle(
                        fontSize: 16,
                  ),
                onChanged: (value) {
                  
                },
              ),
              ),
              Gap(16),
                       Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Styles.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                        color:  const Color(0x20000000),
                        width: 1,
                  ),
                ),
                child:  TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: 'Password'),
                  style: const TextStyle(
                        fontSize: 16,
                  ),
                onChanged: (value) {
                  
                },
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
                    backgroundColor:  _passwordController.text.isEmpty && _nameController.text.isEmpty
                        ? Styles.secondaryAccentColor
                        : const Color(0xff9d6cff),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _passwordController.text.isEmpty && _nameController.text.isEmpty ? _onPressedNext : null,
                  child: Builder(
                    builder: (context) {
                      return Text(
                        AppLocalizations.of(context)!.import_the_account,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }
                  ),
                ),
              ),
               
                     ],
                   )
                    ],
              ),
            ),
            if(isLoading)
            CircularProgressIndicator(color: Styles.primaryAccentColor,),
          ],
        ));
}
}

void showImportAccountQrModal(
    {BuildContext? context, ReefQrCode? data}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ImportAccountQr(data: data), headText: "Import the Account");
}