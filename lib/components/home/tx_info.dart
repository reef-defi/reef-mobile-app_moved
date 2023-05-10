import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/home/WebviewPage.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class TxInfo extends StatefulWidget {
  final String unparsedTimestamp;
  final String? imageUrl;
  final String? iconUrl;
  TxInfo(this.unparsedTimestamp, this.imageUrl, this.iconUrl, {Key? key})
      : super(key: key);

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
      setState(() {
        isDataFetched = true;
        txData = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
                  if (widget.iconUrl != null) IconFromUrl(widget.iconUrl!),
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
                        'Extrinsic Index',
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
                        txData['extrinsicIdx'].toString(),
                        txData['from'],
                        txData['to'],
                        txData['nftId'] == null
                            ? formatAmountToDisplayBigInt(
                                BigInt.parse(txData['amount']),
                                fractionDigits: 2)
                            : txData['amount'] + 'x NFT',
                        formatAmountToDisplayBigInt(BigInt.parse(txData['fee']),
                            fractionDigits: 2),
                        txData['token_address'],
                        txData['token_name'],
                        DateTime.parse(txData['timestamp']).toString(),
                        txData['status']
                      ], fontSizeLabel: 16, fontSizeValue: 16),
                    ),
                  ),
                  // if (widget.iconUrl != null)
                  //   Table(children: [
                  //     TableRow(
                  //       children: [
                  //         Padding(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 4.0, vertical: 4.0),
                  //           child: GradientText(
                  //             "Icon",
                  //             gradient: textGradient(),
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(
                  //                 fontWeight: FontWeight.w600, fontSize: 16),
                  //           ),
                  //         ),
                  //         Expanded(
                  //           child: Padding(
                  //               padding: const EdgeInsets.all(12),
                  //               child: Align(
                  //                 alignment: Alignment.topLeft,
                  //                 child: IconFromUrl(
                  //                   widget.iconUrl!,
                  //                   size: 18,
                  //                 ),
                  //               )),
                  //         ),
                  //       ],
                  //     ),
                  //   ])
                  Gap(16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                              url:
                                  "https://reefscan.com/transfer/${txData['block_number']}/${txData['extrinsicIdx']}/${txData['eventIdx']}"),
                        ),
                      );
                    },
                    child: GradientText(
                      "https://reefscan.com/transfer/${txData['block_number']}/${txData['extrinsicIdx']}/${txData['eventIdx']}",
                      gradient: textGradient(),
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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