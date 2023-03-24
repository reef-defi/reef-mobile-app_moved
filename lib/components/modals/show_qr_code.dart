import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/ReefAppState.dart';

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
          const SizedBox(
            height: 8,
          ),
          Wrap(children: [
            Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  data,
                  style: TextStyle(fontSize: 10),
                ))
          ]),
          const SizedBox(
            height: 8,
          ),
          // ElevatedButton.icon(
          //   icon: Icon(Icons.copy),
          //   onPressed: () async {
          //     var isEvm = data.startsWith('0x');
          //     var addressToCopy = isEvm == true
          //         ? await ReefAppState.instance.accountCtrl
          //             .toReefEVMAddressWithNotificationString(data)
          //         : data;
          //     Clipboard.setData(ClipboardData(text: addressToCopy)).then((_) {
          //       var message = isEvm == true
          //           ? "EVM address copied to clipboard.\nUse it ONLY on Reef Chain!"
          //           : "Native address copied to clipboard.";

          //       ScaffoldMessenger.of(context)
          //           .showSnackBar(SnackBar(content: Text(message)));
          //     });
          //   },
          //   label: Text('Copy to clipboard'),
          // ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(
              AppLocalizations.of(context)!.copy_to_clipboard,
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
              var isEvm = data.startsWith('0x');
              var addressToCopy = isEvm == true
                  ? await ReefAppState.instance.accountCtrl
                      .toReefEVMAddressWithNotificationString(data)
                  : data;
              Clipboard.setData(ClipboardData(text: addressToCopy)).then((_) {
                var message = isEvm == true
                    ? "EVM address copied to clipboard.\nUse it ONLY on Reef Chain!"
                    : "Native address copied to clipboard.";

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

void showQrCode(String title, String message, {BuildContext? context}) {
  showModal(
      context ?? navigatorKey.currentContext,
      child: QRCodeGenerator(
        data: message,
      ),
      headText: title);
}
