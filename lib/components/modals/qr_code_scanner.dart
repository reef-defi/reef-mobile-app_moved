import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:barcode_finder/barcode_finder.dart';

class QrCodeScanner extends StatefulWidget {
  final Function(String)? onScanned;
  const QrCodeScanner({Key? key, this.onScanned}) : super(key: key);

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final GlobalKey _gLobalkey = GlobalKey();
  QRViewController? controller;
  Barcode? result;
  String qrcode = '';

  void qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((event) {
      setState(() {
        result = event;
      });
      if (widget.onScanned != null) {
        widget.onScanned!(result!.code!);
        Navigator.of(context).pop();
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
                    widget.onScanned!(res!);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("This image does not have QR in it.")));
                  }
                },
              ),
            ),
          ],
        ));
  }
}

void showQrCodeScannerModal(String title, Function(String)? onScanned,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: QrCodeScanner(onScanned: onScanned), headText: title);
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
