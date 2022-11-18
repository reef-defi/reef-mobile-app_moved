import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modals/auth_url_list_modal.dart';
import 'package:reef_mobile_app/components/modals/change_password_modal.dart';
import 'package:reef_mobile_app/components/switch_network.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Settings",
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w500,
                  fontSize: 32,
                  color: Colors.grey[800]),
            ),
            const Gap(32),
            const SwitchNetwork(),
    /*Divider(
              color: Styles.textLightColor,
              thickness: 1,
            ),
            const Gap(24),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () => showAuthUrlListModal(context),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.list_bullet,
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Text('Manage Website Access',
                      style: Theme.of(context).textTheme.bodyText1),
                ],
              ),
            ),*/
            const Gap(24),
            Divider(
              color: Styles.textLightColor,
              thickness: 1,
            ),
            const Gap(24),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () =>
                  showChangePasswordModal("Change password", context: context),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.lock_fill,
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Text('Change password',
                      style: Theme.of(context).textTheme.bodyText1),
                ],
              ),
            ),
          ],
        ));
  }
}
