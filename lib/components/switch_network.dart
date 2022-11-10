import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';

import '../utils/styles.dart';

class SwitchNetwork extends StatefulWidget {
  const SwitchNetwork({Key? key}) : super(key: key);

  @override
  State<SwitchNetwork> createState() => _SwitchNetworkState();
}

class _SwitchNetworkState extends State<SwitchNetwork> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Current network:"),
        Text(ReefAppState.instance.networkCtrl.currentNetwork.name),
        Text(
            "Switch to ${ReefAppState.instance.networkCtrl.currentNetwork == Network.mainnet ? Network.testnet.name : Network.mainnet.name}"),
        Switch(
          value: ReefAppState.instance.networkCtrl.currentNetwork ==
              Network.testnet,
          onChanged: (value) {
            setState(() {
              var currentNetwork = value ? Network.testnet : Network.mainnet;
              ReefAppState.instance.networkCtrl.setNetwork(currentNetwork);
            });
          },
          activeColor: Styles.primaryAccentColorDark,
        )
      ],
    );
  }
}
