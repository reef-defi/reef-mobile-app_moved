import 'package:flutter/material.dart';
import 'liquid_edge.dart';

class LiquidEdgeClipper extends CustomClipper<Path> {
  LiquidEdge edge;
  double margin;

  LiquidEdgeClipper(this.edge, {this.margin = 0.0}) : super();

  @override
  Path getClip(Size size) {
    return edge.buildPath(size, margin: margin);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // TODO: optimize?
  }
}
