import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;

  final double? width;
  final double? height;

  final Color? color;

  const SvgIcon(this.assetName, {Key? key, this.width, this.height, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconThemeData theme = IconTheme.of(context);
    return SvgPicture.asset(assetName,
        width: width ?? theme.size,
        height: height ?? theme.size,
        color: color ?? theme.color);
  }
}
