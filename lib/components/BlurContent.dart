import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';

class BlurContent extends StatelessObserverWidget {
  final Widget child;
  final bool isChildBlur

  const BlurContent(this.child, this.isChildBlur, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ...TODO not using Observer widget here, use it in parent and set constructor params - return blured child or normal
    some guides
    https://www.youtube.com/watch?v=1bGeRYH7mZs
    or stackoverflow

  }
}
