import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/import_account_from_qr.dart';
import 'package:reef_mobile_app/components/modals/qr_code_scanner.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:barcode_finder/barcode_finder.dart';

class GetQrTypeData extends StatefulWidget {
  String expectedType;
  GetQrTypeData(@required this.expectedType, {Key? key}) : super(key: key);

  @override
  State<GetQrTypeData> createState() => _GetQrTypeDataState();
}

enum QrTypeData { importAccount, address }

class _GetQrTypeDataState extends State<GetQrTypeData> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  ReefQrCode? qrCodeValue;
  String? qrTypeLabel;
  QrTypeData? qrTypeData;
  var numOfTrials = 3;

  String? getQrDataTypeMessage(String? type) {
    switch (type) {
      case 'address':
        return "This is Account Address , You can send funds here by scanning this QR Code";
      case 'importAccount':
        return "You can import this Account by scanning this QR code and entering the password.";
      case 'invalid':
        return "Invalid QR Code\nThis is not generated by REEF.";
      default:
        return null;
    }
  }

  void actOnQrCodeValue(ReefQrCode qrCode) {
    switch (qrCode.type) {
      case 'address':
        // popping till it is first page or else there will be 2 send page in the stack if we use this widget on SendPage to scan and send
        Navigator.pop(context);
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
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

  void handleQrCodeData(String qrCodeData){
    setState(() {
        try {
          var decoded = jsonDecode(qrCodeData);
          qrCodeValue = ReefQrCode(decoded["type"], decoded["data"]);
        } catch (e) {
          qrCodeValue = const ReefQrCode("invalid", "invalid qr code provided");
        }

        if (widget.expectedType == qrCodeValue?.type) {
          actOnQrCodeValue(qrCodeValue!);
        } else {
          if (widget.expectedType == "info") {
            qrTypeLabel = getQrDataTypeMessage(qrCodeValue?.type);
          } else {
            qrTypeLabel = getQrDataTypeMessage(qrCodeValue?.type);
            qrTypeLabel =
                "Not expected QR Code\n\nAbout this QR : " + qrTypeLabel!;
          }
        }
      });
  }

  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      handleQrCodeData(event.code!);
    }
    );
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
                    Column(
                      children: [
                        Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            child: QRView(key: _gLobalkey, onQRViewCreated: qr),
                          ),
                        ),
                        Gap(16.0),
                        Center(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.crop_free),
                            label: Text(
                              AppLocalizations.of(context)!.scan_from_image,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              shadowColor: const Color(0x559d6cff),
                              elevation: 5,
                              backgroundColor: Styles.primaryAccentColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 28),
                            ),
                            onPressed: () async {
                              try {
                              final res = await scanFile();
                              if (res != Null) {
                                  handleQrCodeData(res!);
                              } 
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File has no QR code")));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  if (qrCodeValue != null)
                    Column(
                      children: [
                        Text(qrTypeLabel ?? ''),
                        Gap(16.0),
                        if (qrCodeValue?.type != "invalid" &&
                            widget.expectedType == "info")
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                actOnQrCodeValue(qrCodeValue!);
                              },
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
                        if (widget.expectedType == qrCodeValue?.type)
                          CircularProgressIndicator(
                            color: Styles.primaryAccentColor,
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

void showQrTypeDataModal(String title, BuildContext context,
    {String expectedType = "info"}) {
  showModal(context, child: GetQrTypeData(expectedType), headText: title);
}

class ReefQrCode {
  final String type;
  final String data;
  const ReefQrCode(this.type, this.data);
}


Future<String?> scanFile() async {
  // Used to pick a file from device storage
  final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image); //can pick image files only
  if (pickedFile != null) {
    final filePath = pickedFile.files.single.path;
    if (filePath != null) {
      final res = await BarcodeFinder.scanFile(path: filePath);
      return res;
    }
  }
}
