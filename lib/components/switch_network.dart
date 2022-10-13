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

class Constants {
  static const String delete = 'Delete';

  static const List<String> choices = <String>[
    delete,
  ];
}

showAlertDialog(BuildContext context, ReefSigner signer) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Yes"),
    onPressed: () {
      ReefAppState.instance.accountCtrl.deleteAccount(signer.address);
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Delete Account"),
    content: Text(
        "Are you sure you want to delete account with name ${signer.name}?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void choiceAction(String choice, BuildContext context, ReefSigner signer) {
  if (choice == Constants.delete) {
    showAlertDialog(context, signer);
  }
}
