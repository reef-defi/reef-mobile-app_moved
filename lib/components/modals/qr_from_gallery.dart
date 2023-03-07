import 'package:flutter/material.dart';
import 'package:scan/scan.dart';
import 'package:images_picker/images_picker.dart';

class QrCodeFromGallery extends StatefulWidget {
  @override
  _QrCodeFromGalleryState createState() => _QrCodeFromGalleryState();
}

class _QrCodeFromGalleryState extends State<QrCodeFromGallery> {
  String qrcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
                children: [
                  Wrap(
                    children: [
                      ElevatedButton(
                        child: Text("Scan from Image"),
                        onPressed: () async {
                          List<Media>? res = await ImagesPicker.pick();
                          if (res != null) {
                            String? str = await Scan.parse(res[0].path);
                            if (str != null) {
                              setState(() {
                                qrcode = str;
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  Text('scan result is $qrcode'),
                ],
              );
            }
}
