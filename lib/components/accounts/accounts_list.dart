import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';

import '../../utils/styles.dart';
import '../account_box.dart';
import '../modals/account_modals.dart';

class AccountsList extends StatelessWidget {
  final List<ReefSigner> signers;
  final void Function(String) selectAddress;
  final String? selectedAddress;
  const AccountsList(this.signers, this.selectedAddress, this.selectAddress,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(0),
      children: signers.isEmpty
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
          : [toAccountBoxList(signers)],
    );
  }

  Widget toAccountBoxList(List<ReefSigner> signers) {
    signers.removeWhere((sig) => sig == null);

    return Wrap(
        spacing: 24,
        children: signers
            .map<Widget>(
              (ReefSigner signer) => Column(
                children: [
                  AccountBox(
                      reefSigner: signer,
                      selected: selectedAddress != null
                          ? selectedAddress == signer.address
                          : false,
                      onSelected: () => selectAddress(signer.address),
                      showOptions: true),
                  const Gap(12)
                ],
              ),
            )
            .toList());
  }
}
