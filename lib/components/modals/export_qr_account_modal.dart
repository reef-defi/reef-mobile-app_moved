import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reef_mobile_app/utils/styles.dart';


class ExportQrAccount extends StatefulWidget {
  const ExportQrAccount(@required this.address,{super.key});
  final String address;

  @override
  State<ExportQrAccount> createState() => _ExportQrAccountState();
}

class _ExportQrAccountState extends State<ExportQrAccount> {
  var data = "";
  bool isData = false;
  TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String errorMessage="";


  void _onPressedNext() async{
    setState(() {
      _isLoading = true;
    });
    String password = _passwordController.text;
    final res = await ReefAppState.instance.accountCtrl.addExternalAccount(widget.address, password);
    if(res == "error"){
      setState(() {
        errorMessage = "Incorrect Password Entered";
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
        isData = true;
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
          if(isData)
          QrImage(
              data: data,
              version: QrVersions.auto,
              size: data.length>50? 400.0:200.0,
              gapless: false,
              foregroundColor: Colors.black,
              embeddedImage: data.length>50?null: const AssetImage('assets/images/reef.png'),
              embeddedImageStyle:  data.length>50?null:QrEmbeddedImageStyle(
                size: const Size(40, 40),
              ),
              errorStateBuilder: (context, error) => const Text(
                "Oops! Something went wrong...",
                style: TextStyle(fontSize: 20.0),
              ),
              semanticsLabel: data,
            ),
            if(!_isLoading && !isData)
                        Column(
                          children: [
            Text("Enter password for ${widget.address}",style: TextStyle(fontSize: 16.0),textAlign: TextAlign.start,),
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
            if(!isData)
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
                        "Export Account",
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
