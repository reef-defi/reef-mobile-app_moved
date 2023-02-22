import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SelectAccount extends StatelessWidget {
  final String signerAddress;
  final Function(String) callback;
  final bool isTokenReef;

  const SelectAccount(this.signerAddress, this.callback, this.isTokenReef,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<StatusDataObject<ReefAccount>> accountList;
    if (this.isTokenReef) {
      accountList = ReefAppState.instance.model.accounts.accountsFDM.data
          .where((accFDM) => accFDM.data.address != signerAddress)
          .toList();
    } else {
      accountList = ReefAppState.instance.model.accounts.accountsFDM.data
          .where((accFDM) =>
              accFDM.data.address != signerAddress &&
              accFDM.data.isEvmClaimed ==
                  true) // only show accounts that have their EVM claimed
          .toList();
    }

    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: accountList.isEmpty
                ? const Text(
                    AppLocalizations.of(context)!.no_other_accounts,
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: accountList
                        .map<Widget>(
                          (StatusDataObject<ReefAccount> account) => Column(
                            children: [
                              AccountBox(
                                  reefAccountFDM: account,
                                  selected: false,
                                  onSelected: () {
                                    callback(account.data.address);
                                    Navigator.of(context).pop();
                                  },
                                  showOptions: false),
                              Gap(10)
                            ],
                          ),
                        )
                        .toList())));
  }
}

void showSelectAccountModal(
    String title, Function(String) callback, bool filterEvmAccounts,
    {BuildContext? context}) async {
  var signerAddress = await ReefAppState.instance.storage
      .getValue(StorageKey.selected_address.name);
  showModal(context ?? navigatorKey.currentContext,
      child: SelectAccount(signerAddress, callback, filterEvmAccounts),
      headText: title,
      background: Styles.darkBackgroundColor,
      textColor: Styles.textLightColor);
}
