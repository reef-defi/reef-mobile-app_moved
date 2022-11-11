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
        Text("Mainnet", style: Theme.of(context).textTheme.bodyText1),
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
        ),
        Text("Testnet", style: Theme.of(context).textTheme.bodyText1),
      ])
    ]);
  }
}
