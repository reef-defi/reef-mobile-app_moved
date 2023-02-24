import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:qr_flutter/qr_flutter.dart';
class QRCodeGenerator extends StatelessWidget {
  final String data;
  const QRCodeGenerator({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          QrImage(
            data: data,
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
            foregroundColor: Colors.black,
            embeddedImage: const AssetImage('assets/images/reef.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: const Size(40, 40),
            ),
            errorStateBuilder: (context, error) => const Text(
              "Oops! Something went wrong...",
              style: TextStyle(fontSize: 20.0),
            ),
            semanticsLabel: data,
          ),
          const SizedBox(height: 16,),
        ],
      ),
    );
  }
}
void showQrCode(String title, String message,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: QRCodeGenerator(data: message,), headText: title);
}
