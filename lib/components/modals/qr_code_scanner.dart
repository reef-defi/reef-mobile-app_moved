import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';

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
              child: QRView(
                    key: _gLobalkey,
                    onQRViewCreated: qr
              ),
            ),
                  ),
                ],
              ),
            ),
            const Gap(8),
           
          ],
        ));
  }
}

void showQrCodeScannerModal(String title,Function(String)? onScanned,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: QrCodeScanner(onScanned: onScanned), headText: title);
}