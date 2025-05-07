import 'package:flutter/material.dart';

class DirectionalPageRoute<T> extends MaterialPageRoute<T> {
  final bool transitionLeftToRight;

  DirectionalPageRoute({
    required super.builder,
    required this.transitionLeftToRight,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == Navigator.defaultRouteName) return child;

    const offsetStart = Offset(-1, 0);
    const offsetEnd = Offset(1, 0);
    const offsetZero = Offset.zero;

    final begin = transitionLeftToRight ? offsetStart : offsetEnd;
    final tween = Tween<Offset>(begin: begin, end: offsetZero).chain(CurveTween(curve: Curves.easeInOut));
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }
}
