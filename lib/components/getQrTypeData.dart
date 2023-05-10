import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/components/modals/import_account_from_qr.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/password_manager.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:barcode_finder/barcode_finder.dart';

class QrDataDisplay extends StatefulWidget {
  ReefQrCodeType? expectedType;

  QrDataDisplay(@required this.expectedType, {Key? key}) : super(key: key);

  @override
  State<QrDataDisplay> createState() => _QrDataDisplayState();
}

class _QrDataDisplayState extends State<QrDataDisplay> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  ReefQrCode? qrCodeValue;
  String? qrTypeLabel;
  var numOfTrials = 3;

  String getQrDataTypeMessage(ReefQrCodeType? type) {
    switch (type) {
      case ReefQrCodeType.address:
        return "This is Account Address , You can send funds here by scanning this QR Code";
      case ReefQrCodeType.accountJson:
        return "You can import this Account by scanning this QR code and entering the password.";
      default:
        return "Not Reef QR Code.";
    }
  }

  void actOnQrCodeValue(ReefQrCode qrCode) async {
    switch (qrCode.type) {
      case ReefQrCodeType.address:
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
      case ReefQrCodeType.accountJson:
        Navigator.pop(context);
        if (await PasswordManager.checkIfPassword()) {
          showImportAccountQrModal(data: qrCode);
        } else {
          showModal(context,
              headText: "Choose Password",
              child: ChangePassword(
                onChanged: () => showImportAccountQrModal(data: qrCode),
              ));
        }
        break;

      default:
        break;
    }
  }

  Future<void> handleQrCodeData(String qrCodeData) async {
    ReefQrCode? qrCode;
    try {
      var decoded = jsonDecode(qrCodeData);
      var qrCodeType = ReefQrCodeType.values.byName(decoded["type"]);
      qrCode = ReefQrCode(qrCodeType, decoded["data"]);
    } on FormatException catch (e) {
      var isAddr = await ReefAppState.instance.accountCtrl
          .isValidSubstrateAddress(qrCodeData);
      if (isAddr && isReefAddrPrefix(qrCodeData)) {
        qrCode = ReefQrCode(ReefQrCodeType.address, qrCodeData);
      }
    }

    setState(() {
      qrCodeValue = qrCode ?? ReefQrCode(ReefQrCodeType.invalid, "");
      if (widget.expectedType != null &&
          widget.expectedType == qrCodeValue?.type) {
        actOnQrCodeValue(qrCodeValue!);
        return;
      }
      qrTypeLabel = getQrDataTypeMessage(qrCodeValue?.type);
    });
  }

  void qr(QRViewController controller) async {
    this.controller = controller;
    /*controller.scannedDataStream.listen((event) {
      handleQrCodeData(event.code!);
    });*/
    var scanRes = await controller.scannedDataStream.first;
    await handleQrCodeData(scanRes.code!);
    this.controller?.dispose();
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Center(
                            child: Container(
                              width: 400,
                              height: 300,
                              child:
                                  QRView(key: _gLobalkey, onQRViewCreated: qr),
                            ),
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
                                  await handleQrCodeData(res!);
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("No Reef QR code")));
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
                        if (qrCodeValue?.type != ReefQrCodeType.invalid &&
                            widget.expectedType == ReefQrCodeType.info)
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
    {ReefQrCodeType? expectedType}) {
  showModal(context, child: QrDataDisplay(expectedType), headText: title);
}

class ReefQrCode {
  final ReefQrCodeType type;
  final String data;

  const ReefQrCode(this.type, this.data);
}

Future<String?> scanFile() async {
  // Used to pick a file from device storage
  final pickedFile = await FilePicker.platform
      .pickFiles(type: FileType.image); //can pick image files only
  if (pickedFile != null) {
    final filePath = pickedFile.files.single.path;
    if (filePath != null) {
      final res = await BarcodeFinder.scanFile(path: filePath);
      return res;
    }
  }
}

enum ReefQrCodeType { address, accountJson, info, invalid }
