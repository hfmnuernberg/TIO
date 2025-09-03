import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class ModalBottomSheet extends StatelessWidget {
  final String label;
  final List<Widget> titleChildren;
  final List<Widget> contentChildren;

  const ModalBottomSheet({super.key, required this.label, required this.titleChildren, required this.contentChildren});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                color: ColorTheme.surface,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Column(children: titleChildren),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: ColorTheme.primary80,
                child: Column(children: contentChildren),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
