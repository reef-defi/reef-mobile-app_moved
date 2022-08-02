import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/accounts/accounts_list.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/AccountCtrl.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../components/SignatureContentToggle.dart';
import '../model/account/ReefSigner.dart';

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);
  final ReefAppState reefState = ReefAppState.instance;
  final AccountCtrl accountCtrl = ReefAppState.instance.accountCtrl;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
                  const Image(
                    image: AssetImage("./assets/images/reef.png"),
                    width: 24,
                    height: 24,
                  ),
                  const Gap(8),
                  Text(
                    "Accounts",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        color: Styles.textColor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.search,
                      color: Styles.textLightColor,
                      size: 28,
                    ),
                  ),
                  const Gap(12),
                  MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      showCreateAccountModal(context);
                    },
                    color: Styles.textLightColor,
                    minWidth: 0,
                    height: 0,
                    padding: const EdgeInsets.all(2),
                    shape: const CircleBorder(),
                    elevation: 0,
                    child: Icon(
                      Icons.add,
                      color: Styles.primaryBackgroundColor,
                      size: 20,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        Observer(builder: (_) {
          if (ReefAppState.instance.model.accounts.loadingSigners == true) {
            return Text(
              'Loading signers...',
              style: TextStyle(fontSize: 16, color: Styles.textLightColor),
            );
          }
          if (ReefAppState.instance.model.accounts.signers.isNotEmpty) {
            // return Text('signers loaded = ${ReefAppState.instance.model.accounts.signers.map((ReefSigner s){
            //   return s.address + ' bal = ' + toBalanceDisplayBigInt(s.balance);
            // }).join('/////')}');
            return Expanded(
                child: AccountsList(
                    ReefAppState.instance.model.accounts.signers,
                    ReefAppState.instance.model.accounts.selectedAddress,
                    ReefAppState.instance.accountCtrl.setSelectedAddress));
          }
          return Text('No signers found');
        }),
      ],
    ));
  }
}
