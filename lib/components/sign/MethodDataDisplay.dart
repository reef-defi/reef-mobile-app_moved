import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/json_big_int.dart';
import '../../model/signing/signature_request.dart';

class MethodDataDisplay extends StatelessWidget {
  const MethodDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
        if (signatureReq != null && signatureReq!.hasResults) {
          var evmMethodData = signatureReq?.decodedMethod['vm']['evm'];
          var isEVM = evmMethodData != null;
          if (isEVM == true) {
            var fragmentData = evmMethodData['decodedData']['functionFragment'];
            var args = List.from(fragmentData['inputs']).asMap().map((i, val) =>
                MapEntry(val['name'],
                    _getValue(evmMethodData['decodedData']['args'][i])));
            Map<String, String> decodedData = {
              "type": "EVM Contract",
              "contract address": evmMethodData['contractAddress'],
              "method name": signatureReq?.decodedMethod['methodName'],
              "args": "${fragmentData['name']}(${args.entries.join(',')})"
            };
            final decodedDetails = createDecodedDataTable(decodedData);
            return Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Table(children: decodedDetails, columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(4),
              }),
            );
          }
          final List<dynamic>? argsList = signatureReq?.decodedMethod['args'];
          final String args = argsList?.join(', ').toString() ?? "";
          final String params = args.length > 1
              ? "${args.split(':')[1].split('}')[0]},${args.split(',')[1]}"
              : "empty";
          Map<String, String> decodedData = {
            "type": "Native Method Call",
            "method name": signatureReq?.decodedMethod['methodName'],
            "params": params
          };
          final decodedDetails = createDecodedDataTable(decodedData);
          return Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: Table(children: decodedDetails, columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(4),
            }),
          );
        }

        return Container();
      }));
}

_getValue(dynamic argVal) {
  if (argVal is String) {
    return argVal;
  }
  try {
    return JsonBigInt.toBigInt(argVal) ?? argVal;
  } catch (e) {
    return argVal;
  }
}

List<TableRow> createDecodedDataTable(Map<String, String> decodedData) {
  List<String> keyTexts = [];
  List<String> valueTexts = [];

  decodedData.forEach((key, value) {
    keyTexts.add(key);
    valueTexts.add(value);
  });

  return createTable(keyTexts: keyTexts, valueTexts: valueTexts);
}

List<TableRow> createTable({required keyTexts, required valueTexts}) {
  List<TableRow> rows = [];
  for (int i = 0; i < keyTexts.length; ++i) {
    rows.add(TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: GradientText(
          keyTexts[i],
          gradient: textGradient(),
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Text(
          valueTexts[i],
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.clip,
        ),
      ),
    ]));
  }
  return rows;
}
