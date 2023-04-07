import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:barcode_finder/barcode_finder.dart';

class ScanAddress extends StatefulWidget {
  final Function(ReefQrCode)? onScanned;
  const ScanAddress({Key? key, this.onScanned}) : super(key: key);

  @override
  State<ScanAddress> createState() => _ScanAddressState();
}

class _ScanAddressState extends State<ScanAddress> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  String qrcode = '';

  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((Barcode result) {
      if (mounted) {
        if (widget.onScanned != null) {
          final returnJson = jsonDecode(result!.code!);
          ReefQrCode qrCode= ReefQrCode(returnJson["type"].toString().trim(), returnJson["data"].toString().trim());
          widget.onScanned!(qrCode);
          Navigator.of(context).pop();
        }
      }
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
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      child: QRView(key: _gLobalkey, onQRViewCreated: qr),
                    ),
                    ),
                ],
              ),
            ),
            const Gap(16),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
                ),
                onPressed: () async {
                  final res = await scanFile();
                  if (res != Null) {
                    ReefQrCode reefQrCode = ReefQrCode(jsonDecode(res!)['type'], jsonDecode(res!)['data']);
                    widget.onScanned!(reefQrCode);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("This image does not have QR in it.")));
                  }
                },
              ),
            ),
            const Gap(8),
          ],
        ));
  }
}

void showAddressScannerModal(String title, Function(ReefQrCode)? onScanned,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: ScanAddress(onScanned: onScanned), headText: title);
}


Future<String?> scanFile() async {
  // Used to pick a file from device storage
  final pickedFile = await FilePicker.platform.pickFiles();
  if (pickedFile != null) {
    final filePath = pickedFile.files.single.path;
    if (filePath != null) {
      final res = await BarcodeFinder.scanFile(path: filePath);
      return res;
    }
  }
}
