import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/generateQrJsonValue.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class ExportQrAccount extends StatefulWidget {
  const ExportQrAccount(@required this.address,{super.key});
  final String address;

  @override
  State<ExportQrAccount> createState() => _ExportQrAccountState();
}

class _ExportQrAccountState extends State<ExportQrAccount> {
  String? data;
  TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String errorMessage="";


  void _onPressedNext() async{
    setState(() {
      _isLoading = true;
    });
    String password = _passwordController.text;
    final res = await ReefAppState.instance.accountCtrl.exportAccountQr(widget.address, password);
    if(res == "error"){
      setState(() {
        errorMessage = AppLocalizations.of(context)!.incorrect_password;
        _isLoading = false;
        _passwordController.text = "";
      });
    }else{
      Map<String,dynamic> response = {};
      response['encoded']=res['exportedJson']['encoded'];
      response['encoding']=res['exportedJson']['encoding'];
      response['address']=res['exportedJson']['address'];
      final resultToSend = jsonEncode(response);
      setState(() {
        data = resultToSend.toString();
        _isLoading = false;
      });
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if(data!=null)
          GenerateQrJsonValue(type: "account-json", data: data!),
            if(!_isLoading && data==null)
                        Column(
                          children: [
            Text("${AppLocalizations.of(context)!.enter_password_for} ${widget.address}",style: TextStyle(fontSize: 16.0),textAlign: TextAlign.start,),
            Gap(8.0),
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
                  setState(() {
                    _isButtonEnabled = _passwordController.text.isEmpty?false:true;
                  });
                },
              ),
              ),
                          ],
                        ),
              if(_isLoading)
              CircularProgressIndicator(
                color: Styles.primaryAccentColor,
              ),
              if(errorMessage!="")Text(errorMessage,style: TextStyle(fontSize: 12.0,color: Styles.errorColor),),
              SizedBox(height: 16),
            if(data==null)
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
                  child: Builder(
                    builder: (context) {
                      return Text(
                        AppLocalizations.of(context)!.export_account,
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
      ),
    );
  }
}

void showExportQrAccount(String title,String accountAddress,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ExportQrAccount(accountAddress), headText: title);
}
