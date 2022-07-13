
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class JsApiServiceContentWrapper extends StatelessWidget {
  final Widget content;
  final JsApiService jsApiService;

  const JsApiServiceContentWrapper({ Key? key, required this.content, required this.jsApiService  }):super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        width: 10.0,
        height: 10.0,
        child: jsApiService.widget,
      ),
      content
    ]);
  }
}
