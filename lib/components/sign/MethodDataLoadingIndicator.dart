import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:mobx/mobx.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/signing/signature_request.dart';

class MethodDataLoadingIndicator extends StatelessWidget {
  const MethodDataLoadingIndicator(this.signatureReq, {Key? key})
      : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Observer(
      builder: (_) => signatureReq?.fetchMethodDataFuture.status ==
              FutureStatus.pending
          ? Center(
              child: Column(children: [
              Text(AppLocalizations.of(context)!.decoding_sign),
              Gap(8),
              LinearProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Styles.primaryAccentColor),
                backgroundColor: Styles.greyColor,
              )
            ]))
          : Container());
}
