import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';

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
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Text('Create new account',
                      style: Theme.of(context).textTheme.bodyText1),
                ],
              ),
            ),
            const Gap(8),
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
                    color: Styles.textLightColor,
                    size: 22,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text('Import account from pre-existing seed',
                        style: Theme.of(context).textTheme.bodyText1),
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
