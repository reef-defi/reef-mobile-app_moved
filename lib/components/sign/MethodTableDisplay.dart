import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/tx_decoded_data.dart';
import 'package:reef_mobile_app/utils/functions.dart';

class DisplayDetailsTable extends StatefulWidget {
  const DisplayDetailsTable(this.signatureReq, {Key? key}) : super(key: key);
  final SignatureRequest? signatureReq;

  @override
  _DisplayDetailsTableState createState() => _DisplayDetailsTableState();
}

class _DisplayDetailsTableState extends State<DisplayDetailsTable> {
  Future<List<TableRow>> _getData() async {
    final account = ReefAppState.instance.model.accounts.accountsFDM.data
        .firstWhere(
            (acc) => acc.data.address == widget.signatureReq?.payload.address,
            orElse: () => throw Exception("Signer not found"));

    final type = widget.signatureReq?.payload.type;
    if (type == "bytes") {
      final bytes = await ReefAppState.instance.signingCtrl
          .bytesString(widget.signatureReq?.payload.data);
      return createTable(keyTexts: [
        "bytes",
      ], valueTexts: [
        bytes,
      ]);
    } else {
      final txDecodedData = await _getTxDecodedData(widget.signatureReq!);
      if (txDecodedData.methodName != null &&
          txDecodedData.methodName!.startsWith("evm.") &&
          !account.data.isEvmClaimed) {
        return [];
      } else {
        return createTransactionTable(txDecodedData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (widget.signatureReq != null && widget.signatureReq!.hasResults) {
        var isEVM = widget.signatureReq?.decodedMethod['evm']
                ['contractAddress'] !=
            null;
        return FutureBuilder<List<TableRow>>(
            future: _getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final detailsTable = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
            });
      }
      return Container();
    });
  }
}


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
