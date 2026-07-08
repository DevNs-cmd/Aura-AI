import 'package:flutter/material.dart';

class LocalizedAdaptiveChipGroup extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final Axis direction;

  const LocalizedAdaptiveChipGroup({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}
