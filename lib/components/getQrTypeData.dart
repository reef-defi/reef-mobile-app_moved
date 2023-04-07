import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/import_account_from_qr.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/utils/styles.dart';


class GetQrTypeData extends StatefulWidget {
  bool isCalledFromSettingsPage;
  GetQrTypeData(@required this.isCalledFromSettingsPage,{Key? key}) : super(key: key);

  @override
  State<GetQrTypeData> createState() => _GetQrTypeDataState();
}

class _GetQrTypeDataState extends State<GetQrTypeData> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  ReefQrCode? qrCodeValue;
  String? qrTypeLabel;
  String? getQrDataTypeMessage(String? type) {
    if (type == null) {
      return 'Qr not recognised.';
    }
    switch (type) {
      case 'address':
        return "This is Account Address , You can send funds here by scanning this QR Code";
      case 'importAccount':
        return "You can import this Account by scanning this QR code and entering the password.";

      default:
        return null;
    }
  }

  void actOnQrCodeValue(ReefQrCode qrCode) {
    switch (qrCode.type) {
      case 'address':
        Navigator.pop(context);
        ReefAppState.instance.navigationCtrl.navigateToSendPage(
            context: context,
            preselected: Constants.REEF_TOKEN_ADDRESS,
            preSelectedTransferAddress: qrCode.data);
        break;
      case 'importAccount':
        Navigator.pop(context);
        showImportAccountQrModal(data: qrCode);
        break;

      default:
        break;
    }
  }

  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        var decoded = jsonDecode(event.code!);
        if (decoded["type"] != null && decoded["data"] != null) {
          qrCodeValue = ReefQrCode(decoded["type"], decoded["data"]);
        }
        if(qrCodeValue?.type!=null && !widget.isCalledFromSettingsPage){
          actOnQrCodeValue(qrCodeValue!);
        }else{
        qrTypeLabel = getQrDataTypeMessage(qrCodeValue?.type);
        }
      });
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
                  if (qrCodeValue == null)
                    Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        child: QRView(key: _gLobalkey, onQRViewCreated: qr),
                      ),
                    ),
                  if (qrCodeValue != null)
                    Column(
                      children: [
                        Text(qrTypeLabel ?? ''),
                        Gap(16.0),
                        if(widget.isCalledFromSettingsPage)
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
                            onPressed: (){
                              print("anuna ${widget.isCalledFromSettingsPage}");
                              actOnQrCodeValue(qrCodeValue!);},
                            child: Builder(builder: (context) {
                              return Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            }),
                          ),
                        ),
                        if(!widget.isCalledFromSettingsPage)
                        CircularProgressIndicator(color: Styles.primaryAccentColor,),
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

void showQrTypeDataModal(String title, BuildContext context) {
  bool isCalledFromSettingsPage = title==AppLocalizations.of(context)!.get_qr_information;
  showModal(context,
      child: GetQrTypeData(isCalledFromSettingsPage), headText: title);
}

class ReefQrCode {
  final String type;
  final String data;
  const ReefQrCode(this.type, this.data);
}
