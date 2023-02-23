import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'side.dart';

import 'liquid_edge.dart';
import 'liquid_edge_clipper.dart';

// Provide Key to the carousel to access the swipeToNext and swipeToPrevious methods from another widget
class LiquidCarousel extends StatefulWidget {
  final List<Widget> children;
  final bool cyclic;
  final BuildContext parentContext;
  final void Function(int)? onSwipe;

  const LiquidCarousel(
      {super.key,
      required this.parentContext,
      required this.children,
      this.cyclic = false,
      this.onSwipe});

  @override
  LiquidCarouselState createState() => LiquidCarouselState();
}

class LiquidCarouselState extends State<LiquidCarousel>
    with TickerProviderStateMixin {
  int _index = 1; // index of the base (bottom) child
  int? _dragIndex; // index of the top child
  Offset? _dragOffset; // starting offset of the drag
  double _dragDirection =
      1; // +1 when dragging left to right, -1 for right to left
  bool _dragCompleted = false; // has the drag successfully resulted in a swipe

  late LiquidEdge _edge;
  late Ticker _ticker;
  final _key = GlobalKey();
  late final AnimationController _previousSwipeController;
  late final AnimationController _previousSwipeControllerFaster;
  late final Animation _previousSwipeDragAnimation;
  late final AnimationController _nextSwipeController;
  late final AnimationController _nextSwipeControllerFaster;
  late final Animation _nextSwipeDragAnimation;
  late final Animation _nextSwipeDragAnimationFaster;
  late final Animation _previousSwipeDragAnimationFaster;

  @override
  void initState() {
    _edge = LiquidEdge(count: 25);
    _ticker = createTicker(_tick)..start();
    super.initState();
    _previousSwipeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        animationBehavior: AnimationBehavior.preserve);
    _previousSwipeDragAnimation =
        Tween<double>(begin: 0, end: 500).animate(_previousSwipeController);
    _previousSwipeControllerFaster = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        animationBehavior: AnimationBehavior.preserve);
    _previousSwipeDragAnimationFaster = Tween<double>(begin: 0, end: 500)
        .animate(_previousSwipeControllerFaster);
    _nextSwipeController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        animationBehavior: AnimationBehavior.preserve);
    _nextSwipeDragAnimation = Tween<double>(
            begin: MediaQuery.of(widget.parentContext).size.width, end: 0)
        .animate(_nextSwipeController);
    _nextSwipeControllerFaster = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        animationBehavior: AnimationBehavior.preserve);
    _nextSwipeDragAnimationFaster = Tween<double>(
            begin: MediaQuery.of(widget.parentContext).size.width, end: 0)
        .animate(_nextSwipeControllerFaster);
  }

  @override
  void dispose() {
    _previousSwipeController.dispose();
    _nextSwipeController.dispose();
    _previousSwipeControllerFaster.dispose();
    _nextSwipeControllerFaster.dispose();
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
        onHorizontalDragStart: (details) {
          if (_previousSwipeController.isAnimating) return;
          if (_nextSwipeController.isAnimating) return;
          _handlePanDown(details, _getSize());
        },
        onHorizontalDragUpdate: (details) {
          _handlePanUpdate(details, _getSize(), 1);
        },
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

  void _handlePanUpdate(DragUpdateDetails details, Size size, int pageDiff) {
    double dx = details.globalPosition.dx - _dragOffset!.dx;
    if (!widget.cyclic) {
      if (details.globalPosition.dx > _dragOffset!.dx && _index == 0) return;
      if (details.globalPosition.dx < _dragOffset!.dx &&
          _index == widget.children.length - 1) return;
    }
    if (!_isSwipeActive(dx, pageDiff)) {
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

  bool _isSwipeActive(double dx, int pageDiff) {
    // check if a swipe is just starting:
    if (_dragDirection == 0.0 && dx.abs() > 20.0) {
      _dragDirection = dx.sign;
      _edge.side = _dragDirection == 1.0 ? Side.left : Side.right;
      setState(() {
        if (_index - (_dragDirection.toInt() * pageDiff) < 0) {
          _dragIndex = widget.children.length - 1;
        } else if (_index - (_dragDirection.toInt() * pageDiff) >
            widget.children.length - 1) {
          _dragIndex = 0;
        } else {
          _dragIndex = _index - (_dragDirection.toInt() * pageDiff);
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

    if ((_index == 1 && _dragDirection == 1) ||
        (_index == widget.children.length - 2 && _dragDirection == -1)) {
      _edge.applyTouchOffset();
      return ratio > 0.5 && availW / width > 0.4;
    }

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

  Future<bool> swipeXNext({int x = 1}) async {
    final verticalOffset =
        ((context.size!.height / 2) - Random().nextInt(400)) + 200;

    _handlePanDown(
        DragStartDetails(
            globalPosition: Offset(context.size!.width, verticalOffset)),
        _getSize());

    if (x == 1) {
      _nextSwipeDragAnimation.addListener(() {
        final d = DragUpdateDetails(
            globalPosition:
                Offset(_nextSwipeDragAnimation.value, verticalOffset));
        _handlePanUpdate(d, _getSize(), x);
      });
      await _nextSwipeController.forward();
      _nextSwipeDragAnimation.removeListener(() {});
      _nextSwipeController.reset();
    } else {
      _nextSwipeDragAnimationFaster.addListener(() {
        final d = DragUpdateDetails(
            globalPosition:
                Offset(_nextSwipeDragAnimationFaster.value, verticalOffset));
        _handlePanUpdate(d, _getSize(), 1);
      });
      await _nextSwipeControllerFaster.forward();
      _nextSwipeDragAnimationFaster.removeListener(() {});
      _nextSwipeControllerFaster.reset();
    }

    return true;
  }

  Future<bool> swipeXPrevious({int x = 1}) async {
    final verticalOffset =
        ((context.size!.height / 2) - Random().nextInt(400)) + 200;

    _handlePanDown(DragStartDetails(globalPosition: Offset(0, verticalOffset)),
        _getSize());
    if (x == 1) {
      _previousSwipeDragAnimation.addListener(() {
        final d = DragUpdateDetails(
            globalPosition:
                Offset(_previousSwipeDragAnimation.value, verticalOffset));
        _handlePanUpdate(d, _getSize(), x);
      });
      await _previousSwipeController.forward();
      _previousSwipeDragAnimation.removeListener(() {});
      _previousSwipeController.reset();
    } else {
      _previousSwipeDragAnimationFaster.addListener(() {
        final d = DragUpdateDetails(
            globalPosition: Offset(
                _previousSwipeDragAnimationFaster.value, verticalOffset));
        _handlePanUpdate(d, _getSize(), 1);
      });
      await _previousSwipeControllerFaster.forward();
      _previousSwipeDragAnimationFaster.removeListener(() {});
      _previousSwipeControllerFaster.reset();
    }
    return true;
  }
}
