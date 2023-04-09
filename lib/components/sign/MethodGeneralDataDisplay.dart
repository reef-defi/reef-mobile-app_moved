import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import '../../model/signing/signature_request.dart';

class MethodGeneralDataDisplay extends StatelessWidget {
  const MethodGeneralDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
        if (signatureReq != null) {
            final txData = signatureReq?.txDecodedData;
        var labels=['Chain:'];
        var values=[isMainnet(signatureReq?.payload.genesisHash)?'Reef Mainnet':toShortDisplay(signatureReq?.payload.genesisHash.toString())];
        var table = createTable(keyTexts: labels, valueTexts: values);
          return Padding(
            padding: EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
            child: Table(
              columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(4),
                },
              children: table,
            ),
          );
        }

        return Container();
      }));
}
