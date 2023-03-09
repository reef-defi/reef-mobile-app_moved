import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/utils/json_big_int.dart';

import '../../model/signing/signature_request.dart';

class MethodDataDisplay extends StatelessWidget {
  const MethodDataDisplay(this.signatureReq, {Key? key}) : super(key: key);

  final SignatureRequest? signatureReq;

  @override
  Widget build(BuildContext context) => Expanded(child: Observer(builder: (_) {
        if (signatureReq != null && signatureReq!.hasResults) {
          var evmMethodData = signatureReq?.decodedMethod['vm']['evm'];
          var isEVM = evmMethodData != null;
          if (isEVM == true) {
            var fragmentData = evmMethodData['decodedData']['functionFragment'];
            var args = List.from(fragmentData['inputs']).asMap().map((i, val) =>
                MapEntry(val['name'],
                    _getValue(evmMethodData['decodedData']['args'][i])));

            print('MATHOD DATAAA ${evmMethodData['decodedData']}');

            return Text(
                'EVM contract: ${evmMethodData['contractAddress']} \n ${fragmentData['name']}(${args.entries.join(',')})/ ${signatureReq?.decodedMethod['methodName']}');
          }
          return Text(
              'native method data here / evm=$isEVM / ${signatureReq?.decodedMethod['methodName']} / params...');
        }

        return Container();
      }));
}

_getValue(dynamic argVal) {
  if (argVal is String) {
    return argVal;
  }
  try {
    return JsonBigInt.toBigInt(argVal) ?? argVal;
  } catch (e) {
    return argVal;
  }
}
