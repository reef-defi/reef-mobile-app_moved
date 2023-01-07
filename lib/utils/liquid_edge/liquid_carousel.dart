import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'side.dart';

import 'liquid_edge.dart';
import 'liquid_edge_clipper.dart';

// Provide Key to the carousel to access the swipeToNext and swipeToPrevious methods from another widget
class LiquidCarousel extends StatefulWidget {
  final List<Widget> children;
  final bool cyclic;
  final void Function(int)? onSwipe;

  const LiquidCarousel(
      {super.key, required this.children, this.cyclic = false, this.onSwipe});

  @override
  LiquidCarouselState createState() => LiquidCarouselState();
}

class LiquidCarouselState extends State<LiquidCarousel>
    with SingleTickerProviderStateMixin {
  int _index = 0; // index of the base (bottom) child
  int? _dragIndex; // index of the top child
  Offset? _dragOffset; // starting offset of the drag
  double _dragDirection =
      1; // +1 when dragging left to right, -1 for right to left
  bool _dragCompleted = false; // has the drag successfully resulted in a swipe

  late LiquidEdge _edge;
  late Ticker _ticker;
  final _key = GlobalKey();

  @override
  void initState() {
    _edge = LiquidEdge(count: 25);
    _ticker = createTicker(_tick)..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration duration) {
    _edge.tick(duration);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int l = widget.children.length;

    return GestureDetector(
        key: _key,
        onHorizontalDragStart: (details) => _handlePanDown(details, _getSize()),
        onHorizontalDragUpdate: (details) =>
            _handlePanUpdate(details, _getSize()),
        onHorizontalDragEnd: (details) => _handlePanEnd(details, _getSize()),
        child: Stack(
          children: <Widget>[
            widget.children[_index % l],
            ClipPath(
              clipBehavior: Clip.hardEdge,
              clipper: LiquidEdgeClipper(_edge, margin: 10.0),
              child: widget.children[(_dragIndex ?? 0) % l],
            ),
          ],
        ));
  }

  Size _getSize() {
    final box = _key.currentContext?.findRenderObject() as RenderBox;
    return box.size;
  }

  void _handlePanDown(DragStartDetails details, Size size) {
    if (_dragIndex != null && _dragCompleted) {
      _index = _dragIndex!;
    }
    _dragIndex = null;

    _dragOffset = details.globalPosition;
    _dragCompleted = false;
    _dragDirection = 0;

    _edge.farEdgeTension = 0.0;
    _edge.edgeTension = 0.01;
    _edge.reset();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    double dx = details.globalPosition.dx - _dragOffset!.dx;
    if (!widget.cyclic) {
      if (details.globalPosition.dx > _dragOffset!.dx && _index == 0) return;
      if (details.globalPosition.dx < _dragOffset!.dx &&
          _index == widget.children.length - 1) return;
    }
    if (!_isSwipeActive(dx)) {
      return;
    }
    if (_isSwipeComplete(dx, size.width)) {
      return;
    }

    if (_dragDirection == -1) {
      dx = size.width + dx;
    }
    _edge.applyTouchOffset(size, Offset(dx, details.localPosition.dy));
  }

  bool _isSwipeActive(double dx) {
    // check if a swipe is just starting:
    if (_dragDirection == 0.0 && dx.abs() > 20.0) {
      _dragDirection = dx.sign;
      _edge.side = _dragDirection == 1.0 ? Side.left : Side.right;
      setState(() {
        if (_index - _dragDirection.toInt() < 0) {
          _dragIndex = widget.children.length - 1;
        } else if (_index - _dragDirection.toInt() >
            widget.children.length - 1) {
          _dragIndex = 0;
        } else {
          _dragIndex = _index - _dragDirection.toInt();
        }
      });
    }
    return _dragDirection != 0.0;
  }

  bool _isSwipeComplete(double dx, double width) {
    if (_dragDirection == 0.0) {
      return false;
    } // haven't started
    if (_dragCompleted) {
      return true;
    } // already done

    // check if swipe is just completed:
    double availW = _dragOffset!.dx;
    if (_dragDirection == 1) {
      availW = width - availW;
    }
    double ratio = dx * _dragDirection / availW;

    if (ratio > 0.4 && availW / width > 0.2) {
      _dragCompleted = true;
      _edge.farEdgeTension = 0.01;
      _edge.edgeTension = 0.0;
      _edge.applyTouchOffset();
      if (widget.onSwipe != null) {
        widget.onSwipe!(_dragIndex ?? 0);
      }
    }
    return _dragCompleted;
  }

  void _handlePanEnd(DragEndDetails details, Size size) {
    _edge.applyTouchOffset();
  }

  void swipeToNext() {
    final d = DragUpdateDetails(
        globalPosition: Offset(-MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2));
    _handlePanDown(
        DragStartDetails(
            globalPosition: Offset(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height / 2)),
        _getSize());
    _handlePanUpdate(d, _getSize());
  }

  void swipeToPrevious() {
    final d = DragUpdateDetails(
        globalPosition: Offset(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2));
    _handlePanDown(
        DragStartDetails(globalPosition: const Offset(0, 0)), _getSize());
    _handlePanUpdate(d, _getSize());
  }
}
