import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

class ImportAccountQr extends StatefulWidget {
  ImportAccountQr({Key? key,this.data}) : super(key: key);
  String? data;
  @override
  State<ImportAccountQr> createState() => _ImportAccountQrState();
  
}

class _ImportAccountQrState extends State<ImportAccountQr> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  bool isData = false;
  var finalRes;
  bool isLoading = false;
  TextEditingController _passwordController = TextEditingController();
  
  void _onPressedNext()async{
    setState(() {
      isLoading = true;
    });
         final response = await ReefAppState.instance.accountCtrl.restoreJson(jsonDecode(finalRes["data"]),_passwordController.text);
        if(response=="error"){
        Navigator.of(context).pop();
        showAlertModal("Invalid QR Code", ["This is an invalid QR code!","You can know more about this QR code from the 'Scan QR' option in Settings "]);
        }else{
        response['svg']=svgData;
        response['mnemonic']="";
        response['name']="Account";
        final importedAccount = StoredAccount.fromString(jsonEncode(response).toString());
        await ReefAppState.instance.accountCtrl.saveAccount(importedAccount);
        Navigator.pop(context);
        }
  }

  void qr(QRViewController controller){
    if(widget.data==null){

    this.controller = controller;
    controller.scannedDataStream.listen((event)async{
     setState(() {
       result = event;
     });
     String resultStr = result!.code!;
     if(resultStr[0]=="{"){
      if(jsonDecode(resultStr)["type"]=="importAccount"){
      setState(() {
        isData = true;
        finalRes = jsonDecode(resultStr);
      });
      }else{
        Navigator.of(context).pop();
        showAlertModal(AppLocalizations.of(context)!.invalid_qr_code, [AppLocalizations.of(context)!.invalid_qr_msg1,AppLocalizations.of(context)!.invalid_qr_msg2]);
      }
     }
    });
    }else{
      
     String resultStr = widget.data!;
     if(resultStr[0]=="{"){
      if(jsonDecode(resultStr)["type"]=="importAccount"){
      setState(() {
        isData = true;
        finalRes = jsonDecode(resultStr);
      });
    }
     }
    }
     

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
                  if(!isData)
                  Center(
                    child: Container(
              height: 200,
              width: 200,
              child: QRView(
                    key: _gLobalkey,
                    onQRViewCreated: qr
              ),
            ),
                  ),
                  if(isData)
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
                    backgroundColor:  _passwordController.text.isEmpty 
                        ? Styles.secondaryAccentColor
                        : const Color(0xff9d6cff),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _passwordController.text.isEmpty ? _onPressedNext : null,
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
    {BuildContext? context, String?data}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ImportAccountQr(data: data), headText: "Import Account from QR");
}