import 'package:flutter/material.dart';

PageRouteBuilder<T> directionalPageRoute<T>({required Widget page, required bool transitionLeftToRight}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const offsetStart = Offset(-1, 0);
      const offsetEnd = Offset(1, 0);
      const offsetZero = Offset.zero;

      final begin = transitionLeftToRight ? offsetStart : offsetEnd;
      final tween = Tween(begin: begin, end: offsetZero).chain(CurveTween(curve: Curves.easeInOut));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
