import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:shimmer/shimmer.dart';

class IconFromUrl extends StatelessWidget {
  final dynamic iconUrl;
  final double? size;

  const IconFromUrl(this.iconUrl, {Key? key, this.size = 24}) : super(key: key);

  String processSvgUrl(String value) {
    if (!value.startsWith("data:image/svg+xml;base64,")) {
      return value;
    }
    value = value.substring(26);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String base64Decoded = stringToBase64.decode(value);
    String uriEncoded = Uri.encodeComponent(base64Decoded);
    return "data:image/svg+xml,$uriEncoded";
  }

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return Icon(CupertinoIcons.question_circle,
          color: Colors.grey[600]!, size: size);
    }

    if (iconUrl.startsWith("data:image/svg+xml")) {
      return SizedBox(
          width: size,
          height: size,
          child: ScalableImageWidget.fromSISource(
              si: ScalableImageSource.fromSvgHttpUrl(
                  Uri.parse(processSvgUrl(iconUrl)))));
    }

    return CachedNetworkImage(
        imageUrl: iconUrl,
        width: size,
        height: size,
        placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[350]!,
              child: Container(
                width: size,
                height: size,
                decoration: ShapeDecoration(
                  color: Colors.grey[350]!,
                  shape: const CircleBorder(),
                ),
              ),
            ),
        errorWidget: (context, url, error) {
          return Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            color: Colors.black12,
            size: size,
          );
        });
  }
}
