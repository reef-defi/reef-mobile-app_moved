import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/tx_decoded_data.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';

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
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]));
  }
  return rows;
}

List<TableRow> createTransactionTable(TxDecodedData txData) {
  List<String> keyTexts = [
    txData.chainName != null ? "Chain" : "Genesis",
    "Version",
    "Nonce"
  ];
  List<String> valueTexts = [
    txData.chainName ?? txData.genesisHash!,
    txData.specVersion,
    txData.nonce
  ];

  if (txData.tip != null) {
    keyTexts.add("Tip");
    valueTexts.add(txData.tip!);
  }

  if (txData.rawMethodData != null) {
    keyTexts.add("Method data");
    valueTexts.add(txData.rawMethodData!);
  } else {
    keyTexts.add("Method");
    keyTexts.add("");
    keyTexts.add("Info");
    valueTexts.add(txData.methodName!);
    valueTexts.add(txData.args!);
    valueTexts.add(txData.info!);
  }

  return createTable(keyTexts: keyTexts, valueTexts: valueTexts);
}

class SignModal extends StatefulWidget {
  final List<TableRow> detailsTable;
  final bool isTransaction;
  final String signatureIndent;
  final ReefSigner signer;
  const SignModal(
      this.detailsTable, this.isTransaction, this.signatureIndent, this.signer,
      {Key? key})
      : super(key: key);

  @override
  State<SignModal> createState() => _SignModalState();
}

class _SignModalState extends State<SignModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          AccountBox(
              reefSigner: widget.signer,
              selected: false,
              onSelected: () => {},
              showOptions: false),
          //BoxContent
          // ViewBoxContainer(
          //   color: Colors.white,
          //   child: Padding(
          //     padding:
          //         const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          //     child: Row(
          //       children: [
          //         Container(
          //           decoration: const BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.black12,
          //           ),
          //           child: SvgPicture.string(
          //             widget.account.svg,
          //             height: 64,
          //             width: 64,
          //           ),
          //         ),
          //         const Gap(12),
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               widget.account.name,
          //               style: TextStyle(
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.w600,
          //                   color: Styles.textColor),
          //             ),
          //             const Gap(4),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               children: [
          //                 const Image(
          //                     image: AssetImage("./assets/images/reef.png"),
          //                     width: 18,
          //                     height: 18),
          //                 const Gap(4),
          //                 GradientText(
          //                   toAmountDisplayBigInt(widget.account.balance),
          //                   style: GoogleFonts.spaceGrotesk(
          //                       fontSize: 14, fontWeight: FontWeight.w700),
          //                   gradient: textGradient(),
          //                 ),
          //               ],
          //             ),
          //             const Gap(2),
          //             Row(
          //               children: [
          //                 Text(
          //                   "Native: ${widget.account.address.shorten()}",
          //                   style: const TextStyle(fontSize: 12),
          //                 ),
          //                 const Gap(2),
          //                 const Icon(
          //                   Icons.copy,
          //                   size: 12,
          //                   color: Colors.black45,
          //                 )
          //               ],
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          //Information Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Table(
              // border: TableBorder.all(color: Colors.black),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(4),
              },
              children: widget.detailsTable,
            ),
          ),
          //Signing Button Section
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 5,
                    backgroundColor: Styles.secondaryAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: Text(
                    widget.isTransaction
                        ? 'Sign the transaction'
                        : 'Sign the message',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Future<TxDecodedData> _getTxDecodedData(SignatureRequest request) async {
  TxDecodedData txDecodedData = TxDecodedData(
    specVersion: hexToDecimalString(request.payload.specVersion),
    nonce: hexToDecimalString(request.payload.nonce),
  );

  // Chain or genesis hash
  var metadata = await ReefAppState.instance.storage
      .getMetadata(request.payload.genesisHash);
  if (metadata != null) {
    txDecodedData.chainName = metadata.chain;
  } else {
    txDecodedData.genesisHash = request.payload.genesisHash;
  }

  // Method data
  dynamic types;
  if (metadata != null &&
      metadata.specVersion ==
          int.parse(request.payload.specVersion.substring(2), radix: 16)) {
    types = metadata.types;
    var decodedMethod = await ReefAppState.instance.signingCtrl
        .decodeMethod(request.payload.method, types);
    txDecodedData.methodName = decodedMethod["methodName"];
    var jsonEncoder = const JsonEncoder.withIndent("  ");
    txDecodedData.args = jsonEncoder.convert(decodedMethod["args"]);
    txDecodedData.info = decodedMethod["info"];
  } else {
    txDecodedData.rawMethodData = request.payload.method;
  }

  // Tip
  if (request.payload.tip != null) {
    txDecodedData.tip = hexToDecimalString(request.payload.tip);
  }

  // Lifetime
  // TODO: era should be an object, instead of a string

  return txDecodedData;
}

void showSigningModal(context, SignatureRequest signatureRequest) async {
  var signer = ReefAppState.instance.model.accounts.signers.firstWhere(
      (sig) => sig.address == signatureRequest.payload.address,
      orElse: () => throw Exception("Signer not found"));

  var signatureIndent = signatureRequest.signatureIdent;

  var type = signatureRequest.payload.type;
  if (type == "bytes") {
    var bytes = await ReefAppState.instance.signingCtrl
        .bytesString(signatureRequest.payload.data);
    List<TableRow> detailsTable = createTable(keyTexts: [
      "bytes",
    ], valueTexts: [
      bytes,
    ]);
    showModal(context,
        child: SignModal(detailsTable, false, signatureIndent, signer),
        dismissible: true,
        headText: "Sign Message");
  } else {
    var txDecodedData = await _getTxDecodedData(signatureRequest);
    List<TableRow> detailsTable = createTransactionTable(txDecodedData);
    showModal(context,
        child: SignModal(detailsTable, true, signatureIndent, signer),
        dismissible: true,
        headText: "Sign Transaction");
  }
}
