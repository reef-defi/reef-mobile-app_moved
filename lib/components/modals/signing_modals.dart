import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
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

class EvmNotClaimedModal extends StatefulWidget {
  final ReefSigner signer;

  const EvmNotClaimedModal(this.signer, {Key? key}) : super(key: key);

  @override
  State<EvmNotClaimedModal> createState() => _EvmNotClaimedModalState();
}

class _EvmNotClaimedModalState extends State<EvmNotClaimedModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountBox(
                reefSigner: widget.signer,
                selected: false,
                onSelected: () {},
                showOptions: false),
            const Gap(16),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      showBindEvmModal(context, bindFor: widget.signer);
                    },
                    child: const Text(
                      'Claim EVM account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}

class SignModal extends StatefulWidget {
  final List<TableRow> detailsTable;
  final bool isTransaction;
  final String signatureIdent;
  final ReefSigner signer;
  const SignModal(
      this.detailsTable, this.isTransaction, this.signatureIdent, this.signer,
      {Key? key})
      : super(key: key);

  @override
  State<SignModal> createState() => _SignModalState();
}

class _SignModalState extends State<SignModal> {
  bool _wrongPassword = false;
  bool _biometricsIsAvailable = false;

  final TextEditingController _passwordController = TextEditingController();
  String password = "";
  static final LocalAuthentication localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      setState(() {
        password = _passwordController.text;
      });
    });
    _checkBiometricsSupport().then((value) {
      setState(() {
        _biometricsIsAvailable = value;
      });
    });
  }

  Future<bool> _checkBiometricsSupport() async {
    final isDeviceSupported = await localAuth.isDeviceSupported();
    final isAvailable = await localAuth.canCheckBiometrics;
    return isAvailable && isDeviceSupported;
  }

  Future<void> authenticateWithPassword(String value) async {
    final storedPassword =
        await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    if (storedPassword == value) {
      setState(() {
        _wrongPassword = false;
        Navigator.pop(context);
        ReefAppState.instance.signingCtrl.confirmSignature(
          widget.signatureIdent,
          widget.signer.address,
        );
      });
    } else {
      setState(() {
        _wrongPassword = true;
      });
    }
  }

  Future<void> authenticateWithBiometrics() async {
    final isValid = await localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics',
        options: const AuthenticationOptions(
            useErrorDialogs: true, stickyAuth: true, biometricOnly: true));
    if (isValid) {
      setState(() {
        _wrongPassword = false;
        Navigator.pop(context);
        ReefAppState.instance.signingCtrl.confirmSignature(
          widget.signatureIdent,
          widget.signer.address,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountBox(
              reefSigner: widget.signer,
              selected: false,
              onSelected: () => {},
              showOptions: false),
          //Information Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(4),
              },
              children: widget.detailsTable,
            ),
          ),
          //Password Section
          // TODO: Allow choosing between password and biometrics
          if (!_biometricsIsAvailable) ...[
            Divider(
              color: Styles.textLightColor,
              thickness: 1,
            ),
            const Gap(12),
            Text(
              "PASSWORD FOR REEF APP",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Styles.textLightColor),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(8),
            if (_wrongPassword)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Styles.errorColor,
                    size: 16,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      "Password is incorrect",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              )
          ],
          const Gap(16),
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
                  onPressed: () {
                    if (_biometricsIsAvailable) {
                      authenticateWithBiometrics();
                    } else {
                      authenticateWithPassword(password);
                    }
                  },
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

  var signatureIdent = signatureRequest.signatureIdent;

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
        child: SignModal(detailsTable, false, signatureIdent, signer),
        dismissible: true,
        headText: "Sign Message");
  } else {
    var txDecodedData = await _getTxDecodedData(signatureRequest);
    if (txDecodedData.methodName != null &&
        txDecodedData.methodName!.startsWith("evm.") &&
        !signer.isEvmClaimed) {
      showModal(context,
          child: EvmNotClaimedModal(signer),
          dismissible: true,
          headText: "EVM account not claimed");
    } else {
      List<TableRow> detailsTable = createTransactionTable(txDecodedData);
      showModal(context,
          child: SignModal(detailsTable, true, signatureIdent, signer),
          dismissible: true,
          headText: "Sign Transaction");
    }
  }
}
