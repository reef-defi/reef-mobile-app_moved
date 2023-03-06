import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/tx_decoded_data.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import 'modals/signing_modals.dart';

class SignatureContentToggle extends StatelessObserverWidget {
  final Widget content;

  const SignatureContentToggle(this.content, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      var requests = ReefAppState.instance.model.signatureRequests.list;
      var signatureRequest = requests.isNotEmpty ? requests.first : null;
      var displayIdx = signatureRequest != null ? 0 : 1;
      // displayIdx = 1; // TODO remove this line
      return IndexedStack(
        index: displayIdx,
        children: [
          Scaffold(
            backgroundColor: Styles.primaryBackgroundColor,
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  AppLocalizations.of(context)!.sign_transaction,
                  style: TextStyle(color: Styles.textColor),
                ),
              ),
              leading: IconButton(
                icon: Image.asset('assets/images/reef.png'),
                onPressed: () {
                },
              ),
              backgroundColor: Styles.primaryBackgroundColor,
              elevation: 0.0,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Styles.textColor,
                  ),
                  onPressed: () {
                    _cancel(signatureRequest);
                  },
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                
                Gap(4),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MethodDataDisplay(signatureRequest),
                      ],
                    ),
                  ),
                ),
                Gap(8),
              ],
            ),
          ),
          content
        ],
      );
    });
  }

  void _confirmSign(SignatureRequest? signatureRequest) {
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl.confirmSignature(
      signatureRequest.signatureIdent,
      signatureRequest.payload.address,
    );
  }

  void _cancel(SignatureRequest? signatureRequest) {
    print('REMMMMMMMMM $signatureRequest');
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl
        .rejectSignature(signatureRequest.signatureIdent);
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Observer(
      builder: (_) =>
          signatureReq?.fetchMethodDataFuture.status == FutureStatus.pending
              ? Expanded(child: const LinearProgressIndicator())
              : Container());
}

// Method to display data
class MethodDataDisplay extends StatefulWidget {
  const MethodDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  State<MethodDataDisplay> createState() => _MethodDataDisplayState();
}

class _MethodDataDisplayState extends State<MethodDataDisplay> {
  bool _wrongPassword = false;
  bool _biometricsIsAvailable = false;

  final TextEditingController _passwordController = TextEditingController();
  String password = "";
  static final LocalAuthentication localAuth = LocalAuthentication();
  bool isTransaction = true;

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

  void _cancel(SignatureRequest? signatureRequest) {
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl
        .rejectSignature(signatureRequest.signatureIdent);
  }

  Future<bool> _checkBiometricsSupport() async {
    final isDeviceSupported = await localAuth.isDeviceSupported();
    final isAvailable = await localAuth.canCheckBiometrics;
    return isAvailable && isDeviceSupported;
  }

  Future<void> authenticateWithPassword(String value) async {
    final signer = ReefAppState.instance.model.accounts.accountsFDM.data
        .firstWhere(
            (acc) => acc.data.address == widget.signatureReq?.payload.address,
            orElse: () => throw Exception("Signer not found"));

    final signatureIdent = widget.signatureReq?.signatureIdent;
    final storedPassword =
        await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    if (storedPassword == value) {
      setState(() {
        _wrongPassword = false;
        ReefAppState.instance.navigationCtrl.navigate(NavigationPage.home);
        Navigator.pop(context);
        ReefAppState.instance.signingCtrl.confirmSignature(
          signatureIdent!,
          signer.data.address,
        );
      });
    } else {
      setState(() {
        _wrongPassword = true;
      });
    }
  }

  Future<void> authenticateWithBiometrics() async {
    final signer = ReefAppState.instance.model.accounts.accountsFDM.data
        .firstWhere(
            (acc) => acc.data.address == widget.signatureReq?.payload.address,
            orElse: () => throw Exception("Signer not found"));

    final signatureIdent = widget.signatureReq?.signatureIdent;
    final isValid = await localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics',
        options: const AuthenticationOptions(
            useErrorDialogs: true, stickyAuth: true, biometricOnly: true));
    if (isValid) {
      setState(() {
        _wrongPassword = false;
        ReefAppState.instance.navigationCtrl.navigate(NavigationPage.home);
        Navigator.pop(context);
        ReefAppState.instance.signingCtrl.confirmSignature(
          signatureIdent!,
          signer.data.address,
        );
      });
    }
  }

  Future<String> _decodeMethod(dynamic request) async {
    dynamic types;
    var metadata = await ReefAppState.instance.storage
        .getMetadata(request.payload.genesisHash);
    if (metadata != null &&
        metadata.specVersion ==
            int.parse(request.payload.specVersion.substring(2), radix: 16)) {
      types = metadata.types;
    }
    var res = await ReefAppState.instance.signingCtrl
        .decodeMethod(request.payload.method);
    return res!['data'] ?? "";
  }

  Future<List<dynamic>> _getData() async {
    final account = ReefAppState.instance.model.accounts.accountsFDM.data
        .firstWhere(
            (acc) => acc.data.address == widget.signatureReq?.payload.address,
            orElse: () => throw Exception("Signer not found"));

    final data = await _decodeMethod(widget.signatureReq!);

    final type = widget.signatureReq?.payload.type;
    if (type == "bytes") {
      final bytes = await ReefAppState.instance.signingCtrl
          .bytesString(widget.signatureReq?.payload.data);
      List<TableRow> detailsTable = createTable(keyTexts: [
        "bytes",
      ], valueTexts: [
        bytes,
      ]);
      isTransaction = false;
      return [detailsTable, account, data];
    } else {
      final txDecodedData = await _getTxDecodedData(widget.signatureReq!);
      if (txDecodedData.methodName != null &&
          txDecodedData.methodName!.startsWith("evm.") &&
          !account.data.isEvmClaimed) {
      } else {
        List<TableRow> detailsTable = createTransactionTable(txDecodedData);
        isTransaction = true;
        return [detailsTable, account, data];
      }
    }
    return [[], account, data];
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Observer(
        builder: (_) {
          if (widget.signatureReq != null && widget.signatureReq!.hasResults) {
            var isEVM = widget.signatureReq?.decodedMethod['evm']
                    ['contractAddress'] !=
                null;
            print('EVM DATA= ${widget.signatureReq?.decodedMethod['evm']}');
            //TODO display title if it's evm or native, display method name, parameter names and values
            // if native also display info

            return FutureBuilder<List<dynamic>>(
              future: _getData(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  List<TableRow> detailsTable = snapshot.data![0];
                  var account = snapshot.data![1];
                  var decodedData = snapshot.data![2];
                  return Column(
                    children: [
                      Text(
                  AppLocalizations.of(context)!.transaction_details,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Styles.textColor,
                  ),
                ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isEVM || isTransaction
                            ? Column(
                                children: [
                                  // Text(
                                  //     'render method data here / evm=$isEVM / ${widget.signatureReq?.decodedMethod['data']}'),
                                  AccountBox(
                                      reefAccountFDM: account,
                                      selected: false,
                                      onSelected: () => {},
                                      showOptions: false),
                                  const Gap(16),
                                  Table(
                                    columnWidths: const {
                                      0: IntrinsicColumnWidth(),
                                      1: FlexColumnWidth(4),
                                    },
                                    children: detailsTable,
                                  ),
                                  decodedData != ""
  ? Container(
      height: 80, // set the height as per your requirement
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.decoded_data,style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Styles.primaryAccentColor,
              ),),
          SingleChildScrollView(
            child: Text(
              "$decodedData",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Styles.greyColor,
              ),
            ),
          ),
        ],
      ),
    )
  : const Gap(0),

                                  if (!_biometricsIsAvailable) ...[
                                    const Divider(
                                      color: Styles.textLightColor,
                                      thickness: 1,
                                    ),
                                    const Gap(12),
                                    Text(
                                      AppLocalizations.of(context)!
                                                      .password_for_reef_app,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Styles.textLightColor),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
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
                                        decoration: const InputDecoration.collapsed(
                                            hintText: ''),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    if (_wrongPassword)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            CupertinoIcons
                                                .exclamationmark_triangle_fill,
                                            color: Styles.errorColor,
                                            size: 16,
                                          ),
                                          const Gap(8),
                                          Flexible(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                      .incorrect_password,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          width: 240.0,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40)),
                                              shadowColor: const Color(0x559d6cff),
                                              elevation: 5,
                                              backgroundColor:
                                                  Styles.secondaryAccentColor,
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 16),
                                            ),
                                            onPressed: () {
                                              if (_biometricsIsAvailable) {
                                                authenticateWithBiometrics();
                                              } else {
                                                authenticateWithPassword(password);
                                              }
                                            },
                                            child: Text(
                                              isTransaction
                                                  ? AppLocalizations.of(context)!
                                                      .sign_transaction
                                                  : AppLocalizations.of(context)!
                                                      .sign_message,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40)),
                                              shadowColor: const Color(0x559d6cff),
                                              elevation: 5,
                                              backgroundColor:
                                                  Styles.primaryAccentColor,
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 16, horizontal: 20),
                                            ),
                                            onPressed: () =>
                                                _cancel(widget.signatureReq),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.cancel, size: 18),
                                                const SizedBox(width: 8),
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AccountBox(
                                      reefAccountFDM: account,
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
                                                borderRadius:
                                                    BorderRadius.circular(40)),
                                            shadowColor: const Color(0x559d6cff),
                                            elevation: 5,
                                            backgroundColor:
                                                Styles.secondaryAccentColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                      .claim_evm_account,
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
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(child: CircularProgressIndicator(
                     valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryAccentColor),
                  ));
                }
              },
            );
          }

          return Container();
        },
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
  final metadata = await ReefAppState.instance.storage
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
    final decodedMethod = await ReefAppState.instance.signingCtrl
        .decodeMethod(request.payload.method, types: types);
    txDecodedData.methodName = decodedMethod["methodName"];
    const jsonEncoder = JsonEncoder.withIndent("  ");
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
