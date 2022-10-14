import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';

class Alert extends StatelessWidget {
  final List<String> messages;
  const Alert(this.messages, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...messages.map((e) => Column(children: [Text(e), const Gap(8)])),
          ],
        ));
  }
}

void showAlertModal(String title, List<String> messages,
    {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: Alert(messages), headText: title);
}
