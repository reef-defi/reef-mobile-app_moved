import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/import_account_from_qr.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class GetQrTypeData extends StatefulWidget {
  const GetQrTypeData({Key? key}) : super(key: key);

  @override
  State<GetQrTypeData> createState() => _GetQrTypeDataState();
  
}

class _GetQrTypeDataState extends State<GetQrTypeData> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  bool isDataFetched = false;
  String displayData = "";

  void getQrData(String type){
  switch(type){
    case 'address':
      setState(() {
        displayData = "This is Account Address , You can send funds here by scanning this QR Code";
      });
      break;
    case 'importAccount':
      setState(() {
        displayData = "You can import this Account by scanning this QR code and entering the password.";
      });
      break;
    
    default:
      break;

  }
}

  void _onPressed(String type){
  switch(type){
    case 'address':
    Navigator.pop(context);
      ReefAppState.instance.navigationCtrl
                              .navigateToSendPage(
                                  context: context, preselected: "0x0000000000000000000000000000000001000000",preSelectedTransferAddress: jsonDecode(result!.code!)["data"]);
      break;
    case 'importAccount':
      Navigator.pop(context);
      showImportAccountQrModal(data: result!.code!);
      break;
    
    default:
      break;

  }
}
  
  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
     setState(() {
       result = event;
       isDataFetched = true;
     });
     getQrData(jsonDecode(result!.code!)["type"]);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  if(!isDataFetched)
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
                  if(isDataFetched)
                  Column(
                    children: [
                      Text(displayData),
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
                    backgroundColor: const Color(0xff9d6cff),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: ()=>_onPressed(jsonDecode(result!.code!)["type"]),
                  child: Builder(
                    builder: (context) {
                      return Text(
                        "Continue",
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
            const Gap(8),
           
          ],
        ));
  }
}

void showQrTypeDataModal(String title,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: GetQrTypeData(), headText: title);
}