import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

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
    ReefAppState.instance.storage.getAllAuthUrls().then((value) => setState(() {
          authUrls = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          if (authUrls.isEmpty)
            const Center(
              child: Text('No website request yet!'),
            )
          else ...[
            ...authUrls.map((AuthUrl authUrl) {
              return Row(
                children: [
                  Text(authUrl.url),
                  const Spacer(),
                  Switch(
                    value: authUrl.isAllowed,
                    onChanged: (value) {
                      setState(() {
                        authUrl.isAllowed = value;
                        ReefAppState.instance.storage.saveAuthUrl(authUrl);
                      });
                    },
                    activeColor: Styles.primaryAccentColorDark,
                  )
                ],
              );
            }).toList(),
            // ElevatedButton(
            //     onPressed: () {
            //       for (var authUrl in authUrls) {
            //         authUrl.delete();
            //       }
            //       setState(() {
            //         authUrls = [];
            //       });
            //     },
            //     child: const Text('Delete all'))
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
