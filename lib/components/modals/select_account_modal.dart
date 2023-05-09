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
  final bool Function(StatusDataObject<ReefAccount>) filterCallback;

  const SelectAccount(
      {required this.signerAddress,
      required this.callback,
      required this.isTokenReef,
      required this.filterCallback,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<StatusDataObject<ReefAccount>> accountList;
    if (isTokenReef) {
      accountList = ReefAppState.instance.model.accounts.accountsFDM.data
          .where((accFDM) => accFDM.data.address != signerAddress)
          .where(filterCallback)
          .toList();
    } else {
      accountList = ReefAppState.instance.model.accounts.accountsFDM.data
          .where((accFDM) =>
              accFDM.data.address != signerAddress &&
              accFDM.data.isEvmClaimed ==
                  true) // only show accounts that have their EVM claimed
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: accountList.isEmpty
          ? Text(
              AppLocalizations.of(context)!.no_other_accounts,
              style: TextStyle(color: Styles.textLightColor),
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
                        const Gap(10),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

void showSelectAccountModal(
    String title, Function(String) callback, bool filterEvmAccounts,
    {bool Function(StatusDataObject<ReefAccount>)? filterCallback,
    BuildContext? context}) async {
  filterCallback ??= (p0) => true;

  var signerAddress = await ReefAppState.instance.storageCtrl
      .getValue(StorageKey.selected_address.name);
  showModal(context ?? navigatorKey.currentContext,
      child: SelectAccount(
          signerAddress: signerAddress,
          callback: callback,
          isTokenReef: filterEvmAccounts,
          filterCallback: filterCallback),
      headText: title,
      background: Styles.darkBackgroundColor,
      textColor: Styles.textLightColor);
}
