import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
import 'package:reef_mobile_app/utils/functions.dart';

import '../utils/elements.dart';
import '../utils/styles.dart';

class AccountBox extends StatefulWidget {
  final FeedbackDataModel<ReefAccount> reefAccountFDM;
  final bool selected;
  final VoidCallback onSelected;
  final bool showOptions;

  const AccountBox(
      {Key? key,
      required this.reefAccountFDM,
      required this.selected,
      required this.onSelected,
      required this.showOptions})
      : super(key: key);

  @override
  State<AccountBox> createState() => _AccountBoxState();
}

class _AccountBoxState extends State<AccountBox> {
  bool showBalance = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onSelected,
      child: PhysicalModel(
          borderRadius: BorderRadius.circular(15),
          elevation: 4,
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment(0, 0.2),
                     end: Alignment(0.1, 1.3),
                    colors: [
                      Color.fromARGB(198, 93, 59, 173),
                       Color.fromARGB(53, 185, 25, 197),
                    ]),
                border: Border.all(
                  color:  const Color(0xFFA93185)
                ),
                borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                if (widget.selected)
                  Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 12, bottom: 5, right: 10, top: 2),
                        decoration: BoxDecoration(
                            color: Styles.primaryAccentColor,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topRight: Radius.circular(12))),
                        child: Text(
                          "Selected",
                          style: TextStyle(
                              color: Styles.whiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black12,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: widget.reefAccountFDM.data.iconSVG != null
                                ? SvgPicture.string(
                                    widget.reefAccountFDM.data.iconSVG!,
                                    height: 64,
                                    width: 64,
                                  )
                                : const SizedBox(
                                    width: 64,
                                    height: 64,
                                  ),
                          ),
                        ),
                      ]),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: buildCentralColumn(widget.reefAccountFDM),
                      )),
                      if (widget.showOptions)
                        Column(
                          children: [
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey.shade100,
                              ),
                              enableFeedback: true,
                              onSelected: (String choice) {
                                choiceAction(choice, context,
                                    widget.reefAccountFDM.data);
                              },
                              tooltip: "More Actions",
                              itemBuilder: (BuildContext context) {
                                return Constants.choices.map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget buildCentralColumn(FeedbackDataModel<ReefAccount> reefAccount) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(reefAccount.data.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ))),
          Row(children: [
            const Image(
                image: AssetImage("./assets/images/reef.png"),
                width: 18,
                height: 18),
            Gap(4),
            Text(
              '${toAmountDisplayBigInt(reefAccount.data.balance)} REEF',
              style: GoogleFonts.poppins(
                color: Colors.purpleAccent.shade100,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          ])
        ],
      ),
      Gap(6),
      Container(color: Colors.purpleAccent.shade100.withAlpha(44), height: 1),
      Gap(6),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text.rich(
              TextSpan(
                text: "Address:",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
                children: <TextSpan>[
                  TextSpan(
                      text: " ${widget.reefAccountFDM.data.address.shorten()} ",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (widget.reefAccountFDM.hasStatus(StatusCode.completeData) &&
                widget.reefAccountFDM.data.isEvmClaimed)
              Text.rich(
                TextSpan(
                  text: "EVM:",
                  style: const TextStyle(fontSize: 10),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          " ${widget.reefAccountFDM.data.evmAddress?.shorten()}",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            if (widget.showOptions &&
                widget.reefAccountFDM.hasStatus(StatusCode.completeData) &&
                !widget.reefAccountFDM.data.isEvmClaimed)
              DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.black87,
                    gradient: textGradient(),
                    borderRadius: BorderRadius.circular(12)),
                child: TextButton(
                    onPressed: () {
                      showBindEvmModal(context,
                          bindFor: widget.reefAccountFDM.data);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(82, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Connect EVM",
                      style: TextStyle(
                          color: Styles.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                    )),
              ),
          ]),
    ]);
  }
}

class Constants {
  static const String delete = 'Delete';
  static const String copyNativeAddress = "Copy Address";
  static const String copyEvmAddress = "Copy Reef EVM Address";

  static const List<String> choices = <String>[
    copyNativeAddress,
    copyEvmAddress,
    delete,
  ];
}

showAlertDialog(BuildContext context, ReefAccount signer) {
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
        "You will delete account with name ${signer.name} ${signer.address?.shorten()}. Continue?"),
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

void choiceAction(
    String choice, BuildContext context, ReefAccount account) async {
  if (choice == Constants.delete) {
    showAlertDialog(context, account);
  } else if (choice == Constants.copyNativeAddress) {
    Clipboard.setData(ClipboardData(text: account.address)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Native Address copied to clipboard")));
    });
  } else if (choice == Constants.copyEvmAddress) {
    Clipboard.setData(ClipboardData(
            text: await ReefAppState.instance.accountCtrl
                .toReefEVMAddressWithNotificationString(account.evmAddress)))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "EVM Address copied to clipboard.\nUse it ONLY on Reef Chain!")));
    });
  }
}
