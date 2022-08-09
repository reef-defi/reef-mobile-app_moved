import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/components/modals/token_selection_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/tokens/Token.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

import '../components/SignatureContentToggle.dart';

class EvmBindPage extends StatefulWidget {
  const EvmBindPage({Key? key}) : super(key: key);

  @override
  State<EvmBindPage> createState() => _EvmBindPageState();
}

class _EvmBindPageState extends State<EvmBindPage> {
  var newNativeAddress = "";

  void _create() async {
    var response = await ReefAppState.instance.accountCtrl.generateAccount();
    var account = StoredAccount.fromString(response);
    newNativeAddress = account.address;
    print("new native address: $newNativeAddress");
    await ReefAppState.instance.accountCtrl.saveAccount(account);
  }

  void _transfer() async {
    TokenWithAmount? reefToken = ReefAppState.instance.model.tokens.tokenList
        .firstWhere((token) => token.address == Constants.REEF_TOKEN_ADDRESS);
    reefToken = reefToken.setAmount("5000000000000000000");

    ReefSigner highestBalanceSigner = ReefAppState
        .instance.model.accounts.signers
        .reduce((curr, next) => curr.balance > next.balance ? curr : next);

    print("Transfer 5 REEF from ${highestBalanceSigner.address}");
    var response = await ReefAppState.instance.transferCtrl.transferTokens(
        highestBalanceSigner.address, newNativeAddress, reefToken);

    print(response);
  }

  void _bind() async {
    var response = await ReefAppState.instance.accountCtrl
        .bindEvmAccount(newNativeAddress);
    // TODO wait for tx to be included in block ?
    print(response);
  }

  void _check() async {
    // TODO signer is not updated after binding
    ReefSigner newSigner = ReefAppState.instance.model.accounts.signers
        .firstWhere((signer) => signer.address == newNativeAddress);
    print(
        "isEvmClaimed ${newSigner.isEvmClaimed} - evmAddress: ${newSigner.evmAddress}");
  }

  void _delete() {
    ReefAppState.instance.accountCtrl.deleteAccount(newNativeAddress);
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          ElevatedButton(
              child: const Text('Create new account'), onPressed: _create),
          ElevatedButton(
              child: const Text('Transfer REEF from another account'),
              onPressed: _transfer),
          ElevatedButton(child: const Text('Bind'), onPressed: _bind),
          ElevatedButton(
              child: const Text('Check if binded'), onPressed: _check),
          ElevatedButton(
              child: const Text('Delete new account'), onPressed: _delete),
        ],
      ),
    ));
  }
}
