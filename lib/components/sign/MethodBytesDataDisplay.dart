import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import '../../model/signing/signature_request.dart';

class MethodBytesDataDisplay extends StatelessWidget {
  MethodBytesDataDisplay(this.signatureReq,this.bytes, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;
  dynamic bytes;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
        if (signatureReq != null && signatureReq!.hasResults) {
        List<TableRow> detailsTable = createTable(keyTexts: [
      "bytes",
    ], valueTexts: [
      bytes,
    ]);

          return Padding(
            padding: EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
            child: Table(
              columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(4),
                },
              children: detailsTable,
            ),
          );
        }

        return Container();
      }));
}
