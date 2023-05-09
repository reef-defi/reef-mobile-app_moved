import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SwitchNetwork extends StatefulWidget {
  const SwitchNetwork({Key? key}) : super(key: key);

  @override
  State<SwitchNetwork> createState() => _SwitchNetworkState();
}

class _SwitchNetworkState extends State<SwitchNetwork> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
      child: Column(children: [
        Row(children: [
          Builder(builder: (context) {
            return Text(AppLocalizations.of(context)!.network,
                style: TextStyle(color: Styles.textLightColor, fontSize: 12));
          }),
        ]),
        Observer(builder: (_) {
          if (ReefAppState.instance.model.network.selectedNetworkSwitching) {
            return Builder(builder: (context) {
              return Text(AppLocalizations.of(context)!.registering_on_network);
            });
          }
          return Row(children: [
            Builder(builder: (context) {
              return Text(AppLocalizations.of(context)!.testnet,
                  style: Theme.of(context).textTheme.bodyText1);
            }),
            Switch(
              // TODO listen to currentNetwork from mobx model
              value: ReefAppState.instance.model.network.selectedNetworkName ==
                  Network.mainnet.name,
              onChanged: (value) {
                setState(() {
                  var currentNetwork =
                      value ? Network.mainnet : Network.testnet;
                  ReefAppState.instance.networkCtrl.setNetwork(currentNetwork);
                });
              },
              activeColor: Styles.primaryAccentColorDark,
            ),
            Builder(builder: (context) {
              return Text(AppLocalizations.of(context)!.mainnet,
                  style: Theme.of(context).textTheme.bodyText1);
            })
          ]);
        }),
      ]),
    );
  }
}

void showSwitchNetworkModal(String title, {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: const SwitchNetwork(), headText: title);
}
