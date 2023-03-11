import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/tx_decoded_data.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/json_big_int.dart';
import '../../model/signing/signature_request.dart';

Future<TxDecodedData> _getTxDecodedData(SignatureRequest request) async {
  TxDecodedData txDecodedData = TxDecodedData(
    specVersion: hexToDecimalString(request.payload.specVersion),
    nonce: hexToDecimalString(request.payload.nonce),
  );

  final metadata = await ReefAppState.instance.storage
      .getMetadata(request.payload.genesisHash);
  if (metadata != null) {
    txDecodedData.chainName = metadata.chain;
  } else {
    txDecodedData.genesisHash = request.payload.genesisHash;
  }
  dynamic types;
  if (metadata != null &&
      metadata.specVersion ==
          int.parse(request.payload.specVersion.substring(2), radix: 16)) {
    types = metadata.types;
    final decodedMethod = await ReefAppState.instance.signingCtrl
        .decodeMethod(request.payload.method, types: types);
    txDecodedData.methodName = decodedMethod["methodName"];
    const jsonEncoder = JsonEncoder.withIndent("  ");
    txDecodedData.args = jsonEncoder.convert(decodedMethod["args"]);
    txDecodedData.info = decodedMethod["info"];
  } else {
    txDecodedData.rawMethodData = request.payload.method;
  }
  if (request.payload.tip != null) {
    txDecodedData.tip = hexToDecimalString(request.payload.tip);
  }
  return txDecodedData;
}


class MethodDataDisplay extends StatefulWidget {
  const MethodDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  _MethodDataDisplayState createState() => _MethodDataDisplayState();
}

class _MethodDataDisplayState extends State<MethodDataDisplay> {
  Future<List<Object>> _getMethodData() async {
    if (widget.signatureReq != null && widget.signatureReq!.hasResults) {
      dynamic detailsTable = [];
      if(widget.signatureReq!=Null){
        var requests = ReefAppState.instance.model.signatureRequests.list;
      var signatureRequest = requests.isNotEmpty ? requests.first : null;
      final txData = await _getTxDecodedData(signatureRequest!);
        detailsTable = createTransactionTable(txData);
      }
    final txDecodedData = await _getTxDecodedData(widget.signatureReq!);
      var evmMethodData = widget.signatureReq?.decodedMethod['vm']['evm'];
      var isEVM = evmMethodData != null;
      print("=====");
      print(widget.signatureReq!.decodedMethod['args']);
      if (isEVM == true) {
        var fragmentData =
            evmMethodData['decodedData']['functionFragment'];
        var args = List.from(fragmentData['inputs']).asMap().map(
            (i, val) => MapEntry(val['name'],
                _getValue(evmMethodData['decodedData']['args'][i])));
        print('MATHOD DATAAA ${evmMethodData['decodedData']}');

        return ['EVM contract: ${evmMethodData['contractAddress']}\n ${fragmentData['name']}(${args.entries.join(',')})/ ${widget.signatureReq?.decodedMethod['methodName']}',detailsTable];
      }

      return ['native method data here\n evm=$isEVM\n method name: ${widget.signatureReq?.decodedMethod['methodName']}\n params: ${widget.signatureReq?.decodedMethod['args'].join(', ').split(':')[1].split('}')[0]},${widget.signatureReq?.decodedMethod['args'].join(', ').split(',')[1]}',detailsTable];
    }
    return ['',[]];
  }

  dynamic _getValue(dynamic argVal) {
    if (argVal is String) {
      return argVal;
    }
    try {
      return JsonBigInt.toBigInt(argVal) ?? argVal;
    } catch (e) {
      return argVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: _getMethodData(),
        key: Key(widget.signatureReq.toString()),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            String details = snapshot.data![0];
            final detailsTable = snapshot.data![1];
            List<TableRow> tableRows = detailsTable.cast<TableRow>();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Table(
                    columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(4),
                              },
                    children: tableRows,
                  ),
                ),
                Text(details),
              ],
            );
          } else {
            return Text("no data");
          }
          return Text("yo");
        },
      ),
    );
  }
}

