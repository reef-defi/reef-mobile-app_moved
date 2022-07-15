
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';

class ReefJsApiWrapper extends StatelessWidget {
  final Widget content;
  final JsApiService jsApiService;

  const ReefJsApiWrapper({ Key? key, required this.content, required this.jsApiService  }):super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      jsApiService.widget,
      content
    ]);
  }
}
