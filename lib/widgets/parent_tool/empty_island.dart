import 'package:flutter/material.dart';

// empty island for empty blog.
// is needed to prevent a weird bug when the previous island and new island have the same type

class EmptyIsland extends StatefulWidget {
  final Function callOnInit;

  const EmptyIsland({super.key, required this.callOnInit});

  @override
  State<EmptyIsland> createState() => _EmptyIslandState();
}

class _EmptyIslandState extends State<EmptyIsland> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.callOnInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
