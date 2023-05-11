import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/components/modals/language_selection_modal.dart';
import 'package:reef_mobile_app/components/switch_network.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showDeveloperSettings = false;
  String? gqlConnState;
  StreamSubscription? gqlConnStateSubs;
  String? providerConnState;
  StreamSubscription? providerConnStateSubs;

  @override
  void dispose() {
    gqlConnStateSubs?.cancel();
    providerConnStateSubs?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    gqlConnStateSubs =
        ReefAppState.instance.networkCtrl.getGqlConnLogs().listen((event) {
      setState(() {
        gqlConnState = event != null && event.isConnected
            ? 'connected'
            : event?.toString();
      });
    });

    providerConnStateSubs = ReefAppState.instance.networkCtrl.getProviderConnLogs().listen((event) {
    setState(() {
        providerConnState = event != null && event.isConnected
            ? 'connected'
            : event?.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
    child: Container(
    height: MediaQuery.of(context).size.height,
        color: Styles.primaryBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(builder: (context) {
              return Text(
                AppLocalizations.of(context)!.settings,
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                    color: Colors.grey[800]),
              );
            }),
            const Gap(24),
            Observer(builder: (_) {
              var navigateOnAccountSwitchVal =
                  ReefAppState.instance.model.appConfig.navigateOnAccountSwitch;

                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(children: [
                    Icon(
                      Icons.home,
                      color: Styles.textLightColor,
                      size: 22,
                    ),
                    Gap(9),
                    Text(
                        AppLocalizations.of(context)!
                            .go_to_home_on_account_switch,
                        style: Theme.of(context).textTheme.bodyLarge)
                  ]),
                  value: navigateOnAccountSwitchVal,
                  onChanged: (newValue) {
                    ReefAppState.instance.appConfigCtrl
                        .setNavigateOnAccountSwitch(newValue == true);
                  },
                  activeColor: Styles.primaryAccentColor,
                );
              }),
              Observer(builder: (_) {
                var navigateOnAccountSwitchVal = ReefAppState
                    .instance.model.appConfig.isBiometricAuthEnabled;

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(children: [
                  Icon(
                    Icons.fingerprint,
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  Gap(9),
                  Text(AppLocalizations.of(context)!.biometric_auth,
                      style: Theme.of(context).textTheme.bodyLarge)
                ]),
                value: navigateOnAccountSwitchVal,
                onChanged: (newValue) {
                  ReefAppState.instance.appConfigCtrl
                      .setBiometricAuth(newValue == true);
                },
                activeColor: Styles.primaryAccentColor,
              );
            }),
            Gap(8),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () => showChangePasswordModal(
                  AppLocalizations.of(context)!.change_password,
                  context: context),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.lock_fill,
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Builder(builder: (context) {
                    return Text(AppLocalizations.of(context)!.change_password,
                        style: Theme.of(context).textTheme.bodyLarge);
                  }),
                ],
              ),
            ),
            const Gap(24),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () => showSelectLanguageModal(
                  AppLocalizations.of(context)!.select_language,
                  context: context),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.globe,
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Builder(builder: (context) {
                    return Text(AppLocalizations.of(context)!.select_language,
                        style: Theme.of(context).textTheme.bodyLarge);
                  }),
                ],
              ),
            ),
            const Gap(12),
            Divider(
              color: Styles.textLightColor,
              thickness: 1,
            ),
            const Gap(24),
            InkWell(
              onTap: () {
                setState(() {
                  _showDeveloperSettings = !_showDeveloperSettings;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.code, color: Styles.textLightColor),
                  const Gap(8),
                  Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.developer_settings,
                      style: Theme.of(context).textTheme.bodyLarge,
                    );
                  }),
                  Expanded(child: Container()),
                  Icon(_showDeveloperSettings
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
            if (_showDeveloperSettings)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                child: Column(
                  children: [
                    FutureBuilder<dynamic>(
                        future:
                            ReefAppState.instance.metadataCtrl.getJsVersions(),
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data);
                          }
                          return const Text('getting version...');
                        }),
                    const Gap(12),
                    Text('GQL conn: ${gqlConnState ?? "getting gql status"}'),
                    const Gap(12),
                    Text('Provider conn: ${providerConnState ?? "getting provider status"}'),
                    const Gap(12),
                    MaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () => showSwitchNetworkModal(
                          AppLocalizations.of(context)!.switch_network,
                          context: context),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.network_wifi_1_bar_rounded,
                            color: Styles.textLightColor,
                            size: 22,
                          ),
                          const Gap(8),
                          Text(AppLocalizations.of(context)!.switch_network,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ))
    );
  }
}
