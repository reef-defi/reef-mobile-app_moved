import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SwitchNetwork extends StatefulWidget {
  const SwitchNetwork({Key? key}) : super(key: key);

  @override
  State<SwitchNetwork> createState() => _SwitchNetworkState();
}

class _SwitchNetworkState extends State<SwitchNetwork> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Text("NETWORK",
            style: TextStyle(color: Styles.textLightColor, fontSize: 16)),
      ]),
      Row(children: [
        Text("Testnet", style: Theme.of(context).textTheme.bodyText1),
        Switch(
          // TODO listen to currentNetwork from mobx model
          value: ReefAppState.instance.networkCtrl.currentNetwork ==
              Network.mainnet,
          onChanged: (value) {
            setState(() {
              var currentNetwork = value ?  Network.mainnet : Network.testnet;
              ReefAppState.instance.networkCtrl.setNetwork(currentNetwork);
            });
          },
          activeColor: Styles.primaryAccentColorDark,
        ),
        Text("Mainnet", style: Theme.of(context).textTheme.bodyText1)
      ])
    ]);
  }
}
