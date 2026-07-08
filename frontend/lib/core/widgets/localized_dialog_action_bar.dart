import 'package:flutter/material.dart';

class LocalizedDialogActionBar extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double overflowSpacing;

  const LocalizedDialogActionBar({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.overflowSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.end,
      spacing: spacing,
      overflowSpacing: overflowSpacing,
      overflowAlignment: OverflowBarAlignment.end,
      overflowDirection: VerticalDirection.down,
      children: children,
    );
  }
}
