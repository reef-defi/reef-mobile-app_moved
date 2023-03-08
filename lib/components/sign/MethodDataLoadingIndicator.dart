import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../../model/signing/signature_request.dart';

class MethodDataLoadingIndicator extends StatelessWidget {
  const MethodDataLoadingIndicator(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Observer(
      builder: (_) =>
      signatureReq?.fetchMethodDataFuture.status == FutureStatus.pending
          ? const Expanded(child: LinearProgressIndicator())
          : Container());
}
