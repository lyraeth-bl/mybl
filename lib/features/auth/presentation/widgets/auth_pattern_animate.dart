import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPatternAnimate extends StatefulWidget {
  const AuthPatternAnimate({super.key, this.color});

  final Color? color;

  @override
  State<AuthPatternAnimate> createState() => _AuthPatternAnimate();
}

class _AuthPatternAnimate extends State<AuthPatternAnimate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorFilter = widget.color != null
        ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
        : null;

    return Stack(
      children: [
        // Upper pattern
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _opacity.drive(
                Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero),
              ),
              child: SvgPicture.asset(
                'assets/images/upper_pattern.svg',
                colorFilter: colorFilter,
              ),
            ),
          ),
        ),

        // Lower pattern
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _opacity.drive(
                Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
              ),
              child: SvgPicture.asset(
                'assets/images/lower_pattern.svg',
                colorFilter: colorFilter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
