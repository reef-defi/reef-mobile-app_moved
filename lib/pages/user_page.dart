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
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/SignatureContentToggle.dart';

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);
  final ReefAppState reefState = ReefAppState.instance;
  final AccountCtrl accountCtrl = ReefAppState.instance.accountCtrl;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
    return SignatureContentToggle(Column(
      children: <Widget>[
        Padding(
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
                        color: Colors.grey[800]),
                  ),
                ],
              ),
              Row(
                children: [
                  MaterialButton(
                    onPressed: () => showAddAccountModal('Add account menu', openModal,
                        context: context),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: 0,
                    height: 36,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black26)),
                    child: Row(children: [
                      Icon(
                        Icons.add_circle_rounded,
                        color: Styles.textLightColor,
                        size: 22,
                      ),
                      const Gap(4),
                      Text(
                        "Add Account",
                        style: GoogleFonts.roboto(
                            color: Styles.textLightColor,
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
        ),
        const Gap(16),
        Observer(builder: (_) {
          if (ReefAppState.instance.model.accounts.loadingSigners == true) {
            return Text(
              'Loading accounts...',
              style: TextStyle(fontSize: 16, color: Styles.textLightColor),
            );
          }
          if (ReefAppState.instance.model.accounts.signers.isNotEmpty) {
            return Expanded(
                child: AccountsList(
                    ReefAppState.instance.model.accounts.signers,
                    ReefAppState.instance.model.accounts.selectedAddress,
                    ReefAppState.instance.accountCtrl.setSelectedAddress)
            );
          }
          return const Text('No accounts present');
        }),
      ],
    ));
  }
}
