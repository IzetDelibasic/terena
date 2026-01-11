import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final bool isList;
  final String title;
  final List<Widget> actions;

  const FullScreenLoader({
    super.key,
    required this.isLoading,
    required this.child,
    required this.isList,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: CircularProgressIndicator()) : child;
  }
}
