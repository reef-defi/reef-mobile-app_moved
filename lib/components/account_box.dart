import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/components/modals/show_qr_code.dart';
import 'package:reef_mobile_app/components/modals/export_qr_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/functions.dart';

import '../utils/styles.dart';
import 'BlurableContent.dart';

class AccountBox extends StatefulWidget {
  final StatusDataObject<ReefAccount> reefAccountFDM;
  final bool selected;
  final VoidCallback onSelected;
  final bool showOptions;
  final bool lightTheme;

  const AccountBox(
      {Key? key,
      required this.reefAccountFDM,
      required this.selected,
      required this.onSelected,
      required this.showOptions,
      this.lightTheme = false})
      : super(key: key);

  @override
  State<AccountBox> createState() => _AccountBoxState();
  void SelectAccount() {
    this.onSelected;
  }
}

class _AccountBoxState extends State<AccountBox> {
  bool showBalance = true;

  @override
  Widget build(BuildContext context) {
    var gradientColors = widget.lightTheme
        ? [
            Color.fromARGB(255, 231, 223, 248),
            Color.fromARGB(194, 200, 220, 250),
          ]
        : [
            Color.fromARGB(198, 37, 19, 79),
            Color.fromARGB(53, 110, 27, 117),
          ];
    return InkWell(
      onTap: widget.onSelected,
      child: PhysicalModel(
          borderRadius: BorderRadius.circular(15),
          elevation: 4,
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(0, 0.2),
                    end: Alignment(0.1, 1.3),
                    colors: gradientColors),
                border: Border.all(
                    color: Color(Styles.purpleColor.value),
                    width: widget.selected ? 3 : 0),
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
                            color: Styles.purpleColor,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                topRight: Radius.circular(12))),
                        child: Text(
                          AppLocalizations.of(context)!.selected,
                          style: TextStyle(
                              color: Styles.whiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 24.0),
                  child: Flex(
                    direction: Axis.horizontal,
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
                        child: buildCentralColumn(
                            widget.reefAccountFDM, widget.lightTheme),
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
                                choiceAction(
                                    choice,
                                    context,
                                    widget.reefAccountFDM.data,
                                    widget.onSelected);
                              },
                              tooltip:
                                  AppLocalizations.of(context)!.more_actions,
                              itemBuilder: (BuildContext context) {
                                return Constants(
                                  delete: AppLocalizations.of(context)!.delete,
                                  shareAddressQr: AppLocalizations.of(context)!
                                      .share_address_qr,
                                  shareEvmQr: AppLocalizations.of(context)!
                                      .share_evm_qr,
                                  exportAccount: AppLocalizations.of(context)!
                                      .export_account,
                                  selectAccount: AppLocalizations.of(context)!
                                      .select_account,
                                ).getConstants().map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                    enabled: widget
                                            .reefAccountFDM.data.isEvmClaimed
                                        ? true
                                        : choice ==
                                                AppLocalizations.of(context)!
                                                    .share_evm_qr
                                            ? false
                                            : true,
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

  Widget buildCentralColumn(
      StatusDataObject<ReefAccount> reefAccount, bool lightTheme) {
    var textColor1 = lightTheme ? Styles.textColor : Colors.white;
    var textColor2 = lightTheme ? Colors.black38 : Styles.textLightColor;
    return Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(reefAccount.data.name,
                      style: GoogleFonts.poppins(
                        color: textColor1,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ))),
              Flexible(
                  child: Flex(direction: Axis.horizontal, children: [
                const Image(
                    image: AssetImage("./assets/images/reef.png"),
                    width: 18,
                    height: 18),
                const Gap(4),
                Observer(builder: (_) {
                  return BlurableContent(
                      Text(
                        '${formatAmountToDisplayBigInt(reefAccount.data.balance)} REEF',
                        style: GoogleFonts.poppins(
                          color: textColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ReefAppState.instance.model.appConfig.displayBalance);
                })
              ]))
            ],
          ),
          Gap(6),
          Container(
              color: Colors.purpleAccent.shade100.withAlpha(44), height: 1),
          Gap(6),
          Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                    child: Text.rich(
                  TextSpan(
                    text: AppLocalizations.of(context)!.address,
                    style: TextStyle(fontSize: 10, color: textColor2),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              " ${widget.reefAccountFDM.data.address.shorten()} ",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                if (widget.reefAccountFDM.hasStatus(StatusCode.completeData) &&
                    widget.reefAccountFDM.data.isEvmClaimed)
                  Flexible(
                      child: Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context)!.reef_evm,
                      style: TextStyle(fontSize: 10, color: textColor2),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              " ${widget.reefAccountFDM.data.evmAddress.shorten()}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                if (widget.showOptions &&
                    widget.reefAccountFDM.hasStatus(StatusCode.completeData) &&
                    !widget.reefAccountFDM.data.isEvmClaimed)
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: Styles.primaryAccentColor,
                        // gradient: textGradient(),
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
                          AppLocalizations.of(context)!.connect_evm,
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
  final String delete;
  final String shareAddressQr;
  final String shareEvmQr;
  final String selectAccount;
  final String exportAccount;

  Constants({
    required this.delete,
    required this.shareAddressQr,
    required this.shareEvmQr,
    required this.exportAccount,
    required this.selectAccount,
  });

  List<String> getConstants() {
    return [selectAccount, shareEvmQr, shareAddressQr, delete, exportAccount];
  }
}

showAlertDialog(BuildContext context, ReefAccount signer) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(AppLocalizations.of(context)!.cancel,
        style: TextStyle(
          color: Styles.blueColor,
        )),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: Row(
      children: [
        Icon(Icons.delete, color: Styles.errorColor),
        const SizedBox(width: 8.0),
        Text(
          "Delete Account",
          style: TextStyle(color: Styles.errorColor),
        ),
      ],
    ),
    onPressed: () {
      ReefAppState.instance.accountCtrl.deleteAccount(signer.address);
      Navigator.of(context).pop();
    },
  );

  // set up the container
  Container container = Container(
    decoration: BoxDecoration(
      color: Styles.primaryBackgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "You will ",
                style: TextStyle(
                  color: Styles.textColor,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: "lose",
                style: TextStyle(
                  color: Styles.errorColor,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: " all balance for ",
                style: TextStyle(
                  color: Styles.textColor,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: "${signer.name}",
                style: TextStyle(
                  color: Styles.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    " ${signer.address.shorten()} ${AppLocalizations.of(context)!.unless_saved}",
                style: TextStyle(
                  color: Styles.textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            cancelButton,
            continueButton,
          ],
        ),
      ],
    ),
  );

  // show the dialog
  showModal(context,
      child: container, headText: AppLocalizations.of(context)!.delete_account);
}

void choiceAction(String choice, BuildContext context, ReefAccount account,
    VoidCallback onSelected) async {
  Constants localizedConstants = Constants(
    delete: AppLocalizations.of(context)!.delete,
    shareAddressQr: AppLocalizations.of(context)!.share_address_qr,
    shareEvmQr: AppLocalizations.of(context)!.share_evm_qr,
    selectAccount: AppLocalizations.of(context)!.select_account,
    exportAccount: AppLocalizations.of(context)!.export_account,
  );
  if (choice == AppLocalizations.of(context)!.delete) {
    showAlertDialog(context, account);
  } else if (choice == AppLocalizations.of(context)!.share_evm_qr) {
    if (account.isEvmClaimed) {
      showQrCode(
          AppLocalizations.of(context)!.share_evm_qr, account.evmAddress);
    }
  } else if (choice == AppLocalizations.of(context)!.share_address_qr) {
    showQrCode(AppLocalizations.of(context)!.share_address_qr, account.address);
  } else if (choice == AppLocalizations.of(context)!.select_account) {
    onSelected();
  } else if (choice == AppLocalizations.of(context)!.export_account) {
    showExportQrAccount(
        AppLocalizations.of(context)!.export_account, account.address);
  }
}
