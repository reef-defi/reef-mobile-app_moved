import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class TxInfo extends StatefulWidget {
  final String unparsedTimestamp;
  final String? imageUrl;
  TxInfo(this.unparsedTimestamp, this.imageUrl, {Key? key}) : super(key: key);

  @override
  State<TxInfo> createState() => _TxInfoState();
}

class _TxInfoState extends State<TxInfo> {
  bool isDataFetched = false;
  Map<String, dynamic> txData = {};

  @override
  void initState() {
    ReefAppState.instance.tokensCtrl
        .getTxInfo(widget.unparsedTimestamp)
        .then((value) {
      print("anuna" + value.toString());
      setState(() {
        isDataFetched = true;
        txData = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 32.0, 8.0),
            child: Text(
              "Transfer Details",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Styles.textColor,
              ),
            ),
          ),
          Gap(8.0),
          if (isDataFetched)
            Column(
              children: [
                if (widget.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: IconFromUrl(
                      widget.imageUrl!,
                      size: 240,
                    ),
                  ),
                Gap(16),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(4),
                    },
                    children: createTable(keyTexts: [
                      'Block No.',
                      'Extrinsic',
                      'From',
                      'To',
                      'Amount',
                      'Fee',
                      'Token Address',
                      'Type',
                      'Timestamp',
                      'Status'
                    ], valueTexts: [
                      txData['block_number'].toString(),
                      txData['extrinsic'],
                      txData['from'],
                      txData['to'],
                      txData['nftId'] == null
                          ? formatAmountToDisplayBigInt(
                              BigInt.parse(txData['amount']),
                              fractionDigits: 2)
                          : txData['amount'],
                      formatAmountToDisplayBigInt(BigInt.parse(txData['fee']),
                          fractionDigits: 2),
                      txData['token_address'],
                      txData['token_name'],
                      DateTime.parse(txData['timestamp']).toString(),
                      txData['status']
                    ], fontSizeLabel: 16, fontSizeValue: 16),
                  ),
                ),
              ],
            ),
          if (!isDataFetched)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Styles.primaryAccentColor,
                  ),
                  Gap(16.0),
                  Text(
                    "fetching tx details...",
                    style: TextStyle(color: Styles.primaryAccentColor),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}

/*
what all to include

- block number 
- age 
- extrinsic
- hash
- from 
- to 
- token name
- token address
- amount
- fee 
- status

*/