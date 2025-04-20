import 'package:flutter/material.dart';

class FadeInUpWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInUpWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  _FadeInUpWidgetState createState() => _FadeInUpWidgetState();
}

class _FadeInUpWidgetState extends State<FadeInUpWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;
  final GlobalKey _key = GlobalKey();
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offsetAnimation =
        Tween<Offset>(begin: Offset(0, 0.2), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
      // Listen to scroll events from the ScrollController
      Scrollable.of(context).position.addListener(_checkVisibility);
    });
  }

  void _checkVisibility() {
    if (!_isAnimating) {
      final RenderBox renderBox =
          _key.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      final viewportHeight = MediaQuery.of(context).size.height;

      if (position.dy < viewportHeight && position.dy + size.height > 0) {
        setState(() {
          _isAnimating = true;
        });
        _controller.forward();
        Scrollable.of(context).position.removeListener(_checkVisibility);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _offsetAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
