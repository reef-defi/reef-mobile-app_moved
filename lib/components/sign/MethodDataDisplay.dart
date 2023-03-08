import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../model/signing/signature_request.dart';

class MethodDataDisplay extends StatelessWidget {
  const MethodDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
        if (signatureReq != null && signatureReq!.hasResults) {
          var isEVM = signatureReq?.decodedMethod['evm'] != null;
          //TODO display title if it's evm or native, display method name, parameter names and values
          // if native also display info
          print('EEEEE ${signatureReq?.decodedMethod['evm']}');
          return Text(
              'render method data here / evm=$isEVM / ${signatureReq?.decodedMethod['methodName']}');
        }

        return Container();
      }));
}
