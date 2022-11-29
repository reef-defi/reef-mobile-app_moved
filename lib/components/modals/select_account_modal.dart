import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';

class SelectAccount extends StatelessWidget {
  final String signerAddress;
  final Function(String) callback;
  const SelectAccount(this.signerAddress, this.callback, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FeedbackDataModel<ReefAccount>> accountList = ReefAppState.instance.model.accounts.accountsFDM.data
        .where((accFDM) => accFDM.data.address != signerAddress)
        .toList();

    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accountList.isEmpty)
              const Text(
                "No other accounts available",
              )
            else
              Wrap(
                  spacing: 24,
                  children: accountList
                      .map<Widget>(
                        (FeedbackDataModel<ReefAccount> account) => Column(
                          children: [
                            AccountBox(
                                reefAccountFDM: account,
                                selected: false,
                                onSelected: () {
                                  callback(account.data.address);
                                  Navigator.of(context).pop();
                                },
                                showOptions: false),
                            const Gap(12)
                          ],
                        ),
                      )
                      .toList())
          ],
        ));
  }
}

void showSelectAccountModal(String title, Function(String) callback,
    {BuildContext? context}) async {
  var signerAddress = await ReefAppState.instance.storage
      .getValue(StorageKey.selected_address.name);
  showModal(context ?? navigatorKey.currentContext,
      child: SelectAccount(signerAddress, callback), headText: title);
}
