import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAccount extends StatelessWidget {
  final Function(String) callback;
  const AddAccount({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...getDivider(),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pop();
                callback('addAccount');
              },
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: Styles.primaryAccentColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Builder(builder: (context) {
                    return Text(
                        AppLocalizations.of(context)!.create_new_account,
                        style: Theme.of(context).textTheme.bodyText1);
                  }),
                ],
              ),
            ),
            ...getDivider(),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pop();
                callback('importAccount');
              },
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    Icons.key,
                    color: Styles.primaryAccentColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Builder(builder: (context) {
                      return Text(
                          AppLocalizations.of(context)!
                              .import_account_from_pre_existing_seed,
                          style: Theme.of(context).textTheme.bodyText1);
                    }),
                  ),
                ],
              ),
            ),
            ...getDivider(),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pop();
                callback('restoreJSON');
              },
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    Icons.settings_backup_restore,
                    color: Styles.primaryAccentColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Builder(
                      builder: (context) {
                        return Text(AppLocalizations.of(context)!.restore_from_json,
                            style: Theme.of(context).textTheme.bodyText1);
                      }
                    ),
                  ),
                ],
              ),
            ),
            ...getDivider(),
            MaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pop();
                callback('importFromQR');
              },
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(
                    Icons.crop_free,
                    color: Styles.primaryAccentColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Builder(
                      builder: (context) {
                        return Text(AppLocalizations.of(context)!.import_from_qr_code,
                            style: Theme.of(context).textTheme.bodyText1);
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

void showAddAccountModal(String title, Function(String) callback,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: AddAccount(callback: callback), headText: title);
}

List<Widget> getDivider(){
  return [const Gap(7),
    const Divider(
      color: Styles.textLightColor,
      thickness: 1,
    ),
    const Gap(7)];
}