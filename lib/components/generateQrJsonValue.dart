import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';

class GenerateQrJsonValue extends StatelessWidget {
  final ReefQrCodeType type;
  final String data;
  const GenerateQrJsonValue({super.key,required this.type,required this.data});

  @override
  Widget build(BuildContext context) {
    print(jsonEncode({"type":type.name,"data":data}).toString());
    return QrImage(
            data: jsonEncode({"type":type.name,"data":data}).toString(),
            version: QrVersions.auto,
            // importAccount QR should be larger otherwise wrong value might be scanned
            size:type!=ReefQrCodeType.accountJson? 200.0:400,
            gapless: false,
            foregroundColor: Colors.black,
            //conditionally showing the REEF icon because the importAccount QR code is really sensitive as it consists of long string as data
            embeddedImage: type!=ReefQrCodeType.accountJson?const AssetImage('assets/images/reef.png'):null,
            embeddedImageStyle: type!=ReefQrCodeType.accountJson?QrEmbeddedImageStyle(
              size: const Size(40, 40),
            ):null,
            errorStateBuilder: (context, error) => const Text(
              "Oops! Something went wrong...",
              style: TextStyle(fontSize: 20.0),
            ),
            semanticsLabel: data,
          );
  }
}