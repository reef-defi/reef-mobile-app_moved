import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_json.dart';
import 'package:reef_mobile_app/utils/elements.dart';
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

class TransactionSigner extends StatefulWidget {
  final SignerPayloadJSON payload;
  const TransactionSigner(this.payload, {Key? key}) : super(key: key);

  @override
  State<TransactionSigner> createState() => _TransactionSignerState();
}

class _TransactionSignerState extends State<TransactionSigner> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          //BoxContent
          ViewBoxContainer(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: const Image(
                        image: NetworkImage(
                            "https://source.unsplash.com/random/128x128"),
                        height: 64,
                        width: 64,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reef-Testnet",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Styles.textColor),
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Image(
                              image: AssetImage("./assets/images/reef.png"),
                              width: 18,
                              height: 18),
                          const Gap(4),
                          GradientText(
                            "0.00",
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w700),
                            gradient: textGradient(),
                          ),
                        ],
                      ),
                      const Gap(2),
                      Row(
                        children: const [
                          Text("Native Address: 5F...gkgDA"),
                          Gap(2),
                          Icon(Icons.copy, size: 12)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //Information Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Table(
              // border: TableBorder.all(color: Colors.black),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(4),
              },
              children: createTable(keyTexts: [
                "Genesis",
                "Version",
                "Nonce",
                "Method Data",
              ], valueTexts: [
                widget.payload.genesisHash,
                widget.payload.specVersion.toString(),
                widget.payload.nonce.toString(),
                widget.payload.method,
              ]),
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
                  child: const Text(
                    'Sign the transaction',
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
      ),
    );
  }
}

class SignMessageSigner extends StatefulWidget {
  const SignMessageSigner({Key? key}) : super(key: key);

  @override
  State<SignMessageSigner> createState() => _SignMessageSignerState();
}

class _SignMessageSignerState extends State<SignMessageSigner> {
  bool value = false;
  bool _isInputEmpty = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController valueContainer = TextEditingController();

  _changeState() {
    setState(() {
      _isInputEmpty = valueContainer.text.isEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    valueContainer.addListener(_changeState);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          //BoxContent
          ViewBoxContainer(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: const Image(
                        image: NetworkImage(
                            "https://source.unsplash.com/random/128x128"),
                        height: 64,
                        width: 64,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reef-Testnet",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Styles.textColor),
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Image(
                              image: AssetImage("./assets/images/reef.png"),
                              width: 18,
                              height: 18),
                          const Gap(4),
                          GradientText(
                            "0.00",
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 14, fontWeight: FontWeight.w700),
                            gradient: textGradient(),
                          ),
                        ],
                      ),
                      const Gap(2),
                      Row(
                        children: const [
                          Text("Native Address: 5F...gkgDA"),
                          Gap(2),
                          Icon(Icons.copy, size: 12)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //Information Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Table(
              // border: TableBorder.all(color: Colors.black),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(4),
              },
              children: createTable(keyTexts: [
                "From",
                "bytes",
              ], valueTexts: [
                "https://dev.sqwid.app",
                "icx8btzr1x",
              ]),
            ),
          ),
          //Signing Button Section
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Gap(4),
                      Text(
                        "PASSWORD FOR THIS ACCOUNT",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Styles.textLightColor,
                          fontSize: 10,
                        ),
                      ),
                      const Gap(4),
                      TextFormField(
                        controller: valueContainer,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(
                                color: Styles.secondaryAccentColor, width: 2),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    fillColor: MaterialStateProperty.all<Color>(
                        Styles.secondaryAccentColor),
                    value: value,
                    onChanged: (bool? value) {
                      setState(() {
                        this.value = value ?? false;
                      });
                    },
                  ),
                  Flexible(
                    child: Text(
                      "Remember my password for the next 15 minutes",
                      style:
                          TextStyle(color: Styles.textLightColor, fontSize: 12),
                    ),
                  )
                ],
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    primary: Styles.secondaryAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Sign the transaction',
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
      ),
    );
  }
}

void showSigningModal(context, SignatureRequest signatureRequest) {
  var isTransaction = true;
  showModal(context,
      child: isTransaction
          ? TransactionSigner(signatureRequest.payload)
          : SignMessageSigner(),
      dismissible: true,
      headText: isTransaction ? "Sign Transaction" : "Sign Message");
}
