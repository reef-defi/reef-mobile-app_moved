import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:scan/scan.dart';
import 'package:images_picker/images_picker.dart';

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
  String qrcode = 'Unknown';

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
                label:  Text(
    "Scan from Image",
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
              ),
                onPressed: () async {
                  List<Media>? res = await ImagesPicker.pick();
                  if (res != null) {
                    String? str = await Scan.parse(res[0].path);
                    if (str != null) {
                      setState(() {
                        qrcode = str;
                      });
                      widget.onScanned!(str);
                      Navigator.of(context).pop();
                    }else{
                      ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("This image does not have QR in it.")));
                    }
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
