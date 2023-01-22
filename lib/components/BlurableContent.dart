import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/components/modals/signing_modals.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';

class BlurableContent extends StatelessObserverWidget {
  final Widget child;
  final bool isChildBlur;

  const BlurableContent(this.child, this.isChildBlur, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(!isChildBlur){
      return ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 23.0,sigmaY: 23.0),child: child);
    }
    return child;
  }
}