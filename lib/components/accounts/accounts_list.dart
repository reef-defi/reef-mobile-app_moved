import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';

import '../../utils/styles.dart';
import '../account_box.dart';
import '../modals/account_modals.dart';

class AccountsList extends StatelessWidget {
  final List<StatusDataObject<ReefAccount>> accounts;
  final void Function(String) selectAddress;
  final String? selectedAddress;
  const AccountsList(this.accounts, this.selectedAddress, this.selectAddress,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(0),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: accounts.isEmpty
          ? [
              DottedBorder(
                dashPattern: const [4, 2],
                color: Styles.textLightColor,
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.click_on,
                            style: TextStyle(color: Styles.textLightColor),
                          ),
                          const Gap(2),
                          MaterialButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onPressed: () {
                              showCreateAccountModal(context);
                            },
                            color: Styles.textLightColor,
                            minWidth: 0,
                            height: 0,
                            padding: const EdgeInsets.all(2),
                            shape: const CircleBorder(),
                            elevation: 0,
                            child: const Icon(
                              Icons.add,
                              color: Styles.primaryBackgroundColor,
                              size: 15,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            AppLocalizations.of(context)!.to_create_account,
                            style: TextStyle(color: Styles.textLightColor),
                          ),
                        ],
                      )),
                ),
              )
            ]
          : [toAccountBoxList(accounts)],
    );
  }

  Widget toAccountBoxList(List<StatusDataObject<ReefAccount>> signers) {
    signers.removeWhere((sig) => sig == null);

    Widget selectedWidget = Container();
    List<Widget> modifiedList = [];

    for (var acc in signers) {
      if (selectedAddress != null && selectedAddress == acc.data.address) {
        selectedWidget = Column(
          children: [
            AccountBox(
                reefAccountFDM: acc,
                selected: true,
                onSelected: () => {},
                showOptions: true),
            const Gap(12)
          ],
        );
      } else {
        modifiedList.add(Column(
          children: [
            AccountBox(
                reefAccountFDM: acc,
                selected: false,
                onSelected: () => selectAddress(acc.data.address),
                showOptions: true),
            const Gap(12)
          ],
        ));
      }
    }

    if (signers.length > 1) {
      modifiedList.insert(
          0,
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8),
              child: Builder(builder: (context) {
                return Text(
                  AppLocalizations.of(context)!.available,
                  style: TextStyle(color: Styles.textLightColor, fontSize: 20.0),
                );
              }),
            ),
          ]));
    }
    if (selectedWidget != null) {
      modifiedList.insert(0, selectedWidget);
    }

    return Wrap(spacing: 24, children: modifiedList);
  }
}
