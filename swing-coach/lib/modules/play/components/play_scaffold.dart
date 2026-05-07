import 'package:flutter/material.dart';

class PlayScaffold extends StatelessWidget {
  const PlayScaffold({required this.child, this.title, super.key});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null ? null : AppBar(title: Text(title!)),
      body: SafeArea(child: child),
    );
  }
}
