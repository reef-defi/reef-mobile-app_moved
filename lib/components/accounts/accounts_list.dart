import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';

import '../../utils/styles.dart';
import '../account_box.dart';
import '../modals/account_modals.dart';

class AccountsList extends StatelessWidget {
  final List<FeedbackDataModel<ReefAccount>> accounts;
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
                            "Click on ",
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
                            " to create a new account",
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

//   Widget toAccountBoxList(List<FeedbackDataModel<ReefAccount>> signers) {
//     signers.removeWhere((sig) => sig == null);

//     return Wrap(
//         spacing: 24,
//         children: signers
//             .map<Widget>(
//               (FeedbackDataModel<ReefAccount> acc) => Column(
//                 children: [
//                   AccountBox(
//                       reefAccountFDM: acc,
//                       selected: selectedAddress != null
//                           ? selectedAddress == acc.data.address
//                           : false,
//                       onSelected: () => selectAddress(acc.data.address),
//                       showOptions: true),
//                   const Gap(12)
//                 ],
//               ),
//             )
//             .toList());
//   }
// }

  Widget toAccountBoxList(List<FeedbackDataModel<ReefAccount>> signers) {
    signers.removeWhere((sig) => sig == null);

    Widget selectedWidget;
    List<Widget> modifiedList = signers
        .map<Widget>((FeedbackDataModel<ReefAccount> acc) {
          if (selectedAddress != null && selectedAddress == acc.data.address) {
            selectedWidget = Column(
              children: [
                AccountBox(
                    reefAccountFDM: acc,
                    selected: true,
                    onSelected: () => selectAddress(acc.data.address),
                    showOptions: true),
                const Gap(12)
              ],
            );
            return Gap(0.0);
          } else {
            return Column(
              children: [
                AccountBox(
                    reefAccountFDM: acc,
                    selected: false,
                    onSelected: () => selectAddress(acc.data.address),
                    showOptions: true),
                const Gap(12)
              ],
            );
          }
        })
        .where((widget) => widget != null)
        .toList();

    print("this is the modified list");
    List<Widget> modifiedList2 = signers
        .map<Widget>((FeedbackDataModel<ReefAccount> acc) {
          if (selectedAddress != null && selectedAddress != acc.data.address) {
            selectedWidget = Column(
              children: [
                AccountBox(
                    reefAccountFDM: acc,
                    selected: true,
                    onSelected: () => selectAddress(acc.data.address),
                    showOptions: true),
                const Gap(12)
              ],
            );
            return Gap(0.0);
          } else {
            return Column(
              children: [
                AccountBox(
                    reefAccountFDM: acc,
                    selected: false,
                    onSelected: () => selectAddress(acc.data.address),
                    showOptions: true),
                const Gap(12)
              ],
            );
          }
        })
        .where((widget) => widget != null)
        .toList();

    modifiedList.insert(
        0,
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "All Accounts",
              style: TextStyle(color: Styles.whiteColor, fontSize: 20.0),
            ),
          ),
        ]));
    modifiedList2.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Selected Account",
            style: TextStyle(color: Styles.whiteColor, fontSize: 20.0),
          ),
        ));
    List<Widget> combinedList = List.of(modifiedList2);
    combinedList.addAll(modifiedList);
    return Wrap(spacing: 24, children: combinedList);
  }
}
