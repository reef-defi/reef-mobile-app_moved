import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/accounts/accounts_list.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/components/modals/add_account_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/AccountCtrl.dart';
import 'package:reef_mobile_app/model/feedback-data-model/FeedbackDataModel.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/SignatureContentToggle.dart';

class AccountsPage extends StatefulWidget {
  AccountsPage({Key? key}) : super(key: key);
  final ReefAppState reefState = ReefAppState.instance;
  final AccountCtrl accountCtrl = ReefAppState.instance.accountCtrl;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  // TODO replace strings with enum
  void openModal(String modalName) {
    switch (modalName) {
      case 'addAccount':
        showCreateAccountModal(context);
        break;
      case 'importAccount':
        showCreateAccountModal(context, fromMnemonic: true);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: Color.fromARGB(255, 86, 54, 162),
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
                    ReefAppState.instance.accountCtrl.setSelectedAddress));
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
              Text(
                "Accounts",
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                    color: Colors.grey.shade100),
              ),
            ],
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () => showAddAccountModal(
                    'Add account menu', openModal,
                    context: context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: 0,
                height: 36,
                elevation: 0,
                color: Colors.purple,
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black26)),
                child: Row(children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: Colors.grey.shade100,
                    size: 22,
                  ),
                  const Gap(4),
                  Text(
                    "Add Account",
                    style: GoogleFonts.roboto(
                        color: Colors.grey.shade100,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )
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
