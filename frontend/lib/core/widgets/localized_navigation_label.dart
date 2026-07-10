import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocalizedNavigationLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;

  const LocalizedNavigationLabel({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: color,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
