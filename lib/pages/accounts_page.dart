import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/accounts/accounts_list.dart';
import 'package:reef_mobile_app/components/getQrTypeData.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/components/modals/export_qr_account_modal.dart';
import 'package:reef_mobile_app/components/modals/import_account_from_qr.dart';
import 'package:reef_mobile_app/components/modals/restore_json_modal.dart';
import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/AccountCtrl.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/account_profile.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/sign/SignatureContentToggle.dart';

class AccountsPage extends StatefulWidget {
  AccountsPage({Key? key}) : super(key: key);
  final ReefAppState reefState = ReefAppState.instance;
  final AccountCtrl accountCtrl = ReefAppState.instance.accountCtrl;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final svgData = AccountProfile.iconSvg;

  // TODO replace strings with enum
  void openModal(String modalName) {
    switch (modalName) {
      case 'addAccount':
        showCreateAccountModal(context);
        break;
      case 'importAccount':
        showCreateAccountModal(context, fromMnemonic: true);
        break;
      case 'restoreJSON':
        showRestoreJson(context);
        break;
      case 'importFromQR':
        showQrTypeDataModal(
            AppLocalizations.of(context)!.import_the_account, context,
            expectedType: ReefQrCodeType.accountJson);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Styles.darkBackgroundColor,
      // color: Color.fromARGB(255, 86, 54, 162),
      child: Column(
        children: <Widget>[
          buildHeader(context),
          const Gap(16),
          Observer(builder: (_) {
            var accsFeedbackDataModel =
                ReefAppState.instance.model.accounts.accountsFDM;
            if (accsFeedbackDataModel.hasStatus(StatusCode.completeData)) {
              return const SizedBox.shrink();
            }
            return SizedBox(
                child: Text(
              accsFeedbackDataModel.statusList[0].message ?? '',
              style: TextStyle(fontSize: 16, color: Styles.textLightColor),
            ));
          }),
          Observer(builder: (_) {
            final accsFeedbackDataModel =
                ReefAppState.instance.model.accounts.accountsFDM;
            if (accsFeedbackDataModel.data.isEmpty) {
              return const SizedBox.shrink();
            }
            // return Text('len=${accsFeedbackDataModel.data.length}');
            return Flexible(
                child: AccountsList(
                    ReefAppState.instance.model.accounts.accountsFDM.data,
                    ReefAppState.instance.model.accounts.selectedAddress,
                    (addr) async {
              await ReefAppState.instance.accountCtrl.setSelectedAddress(addr);
              ReefAppState.instance.navigationCtrl.navigateHomePage(0);

              var navigateOnAccountSwitch =
                  ReefAppState.instance.model.appConfig.navigateOnAccountSwitch;
              if (navigateOnAccountSwitch)
                ReefAppState.instance.navigationCtrl
                    .navigate(NavigationPage.home);
            }));
          }),
        ],
      ),
    ));
  }

  Padding buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // const Image(
              //   image: AssetImage("./assets/images/reef.png"),
              //   width: 24,
              //   height: 24,
              // ),
              const Gap(8),
              Builder(builder: (context) {
                return Text(
                  AppLocalizations.of(context)!.my_account,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w500,
                      fontSize: 32,
                      color: Colors.grey.shade100),
                );
              }),
            ],
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () => showAddAccountModal(
                    AppLocalizations.of(context)!.add_account, openModal,
                    context: context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: 0,
                height: 36,
                elevation: 0,
                color: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Styles.purpleColor)),
                child: Row(children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: Styles.purpleColor,
                    size: 22,
                  ),
                  const Gap(4),
                  Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.add,
                      style: GoogleFonts.roboto(
                          color: Colors.grey.shade100,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    );
                  })
                ]),
              ),
              const Gap(8)
            ],
          ),
        ],
      ),
    );
  }
}
