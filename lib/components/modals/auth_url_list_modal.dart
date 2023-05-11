import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthUrlList extends StatefulWidget {
  const AuthUrlList({Key? key}) : super(key: key);

  @override
  State<AuthUrlList> createState() => _AuthUrlListState();
}

class _AuthUrlListState extends State<AuthUrlList> {
  List<AuthUrl> authUrls = [];

  @override
  void initState() {
    super.initState();
    ReefAppState.instance.storageCtrl
        .getAllAuthUrls()
        .then((value) => setState(() {
              authUrls = value;
            }));
  }

  showAlertDialog(BuildContext context, AuthUrl authUrl) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(AppLocalizations.of(context)!.yes),
      onPressed: () {
        authUrl.delete();
        setState(() {
          authUrls.remove(authUrl);
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.auth_url_list_del),
      content: Text(
          "${AppLocalizations.of(context)!.delete_website_url} ${authUrl.url}?"),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 32.0),
      child: Column(
        children: [
          if (authUrls.isEmpty)
            Center(
              child: Text(
                  AppLocalizations.of(context)!.auth_url_list_no_website_yet),
            )
          else ...[
            ...authUrls.map((AuthUrl authUrl) {
              return Row(
                children: [
                  Text(authUrl.url),
                  const Spacer(),
                  Row(children: [
                    Switch(
                      value: authUrl.isAllowed,
                      onChanged: (value) {
                        setState(() {
                          authUrl.isAllowed = value;
                          ReefAppState.instance.storageCtrl
                              .saveAuthUrl(authUrl);
                        });
                      },
                      activeColor: Styles.primaryAccentColorDark,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          size: 24, color: Styles.primaryAccentColor),
                      onPressed: () => showAlertDialog(context, authUrl),
                    )
                  ])
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}

void showAuthUrlListModal(BuildContext context) {
  showModal(context,
      child: const AuthUrlList(), headText: "Manage Website Access");
}
