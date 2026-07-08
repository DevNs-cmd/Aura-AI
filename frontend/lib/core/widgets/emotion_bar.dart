import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../theme/theme_provider.dart';
import '../localization/generated/app_localizations.dart';

class EmotionBarItemData {
  final String label;
  double percentage; // value from 0.0 to 1.0
  final Color color;

  EmotionBarItemData({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class EmotionBar extends ConsumerStatefulWidget {
  final List<EmotionBarItemData>? items;
  final Function(List<EmotionBarItemData>)? onChanged;

  const EmotionBar({super.key, this.items, this.onChanged});

  @override
  ConsumerState<EmotionBar> createState() => _EmotionBarState();
}

class _EmotionBarState extends ConsumerState<EmotionBar> {
  late List<EmotionBarItemData> _items;

  String _getLocalLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (label.toLowerCase()) {
      case 'happy':
        return l10n.emotionHappy;
      case 'sad':
        return l10n.emotionSad;
      case 'calm':
        return l10n.emotionCalm;
      case 'anxious':
        return l10n.emotionAnxious;
      default:
        return label;
    }
  }

  @override
  void initState() {
    super.initState();
    _items =
        widget.items ??
        [
          EmotionBarItemData(
            label: 'Happy',
            percentage: 0.48,
            color: AppColors.primary,
          ),
          EmotionBarItemData(
            label: 'Sad',
            percentage: 0.33,
            color: const Color(0xFF7E3D31),
          ), // Brownish-lavender
          EmotionBarItemData(
            label: 'Calm',
            percentage: 0.27,
            color: AppColors.success,
          ),
          EmotionBarItemData(
            label: 'Anxious',
            percentage: 0.40,
            color: const Color(0xFF6E6E66),
          ), // Charcoal/Anxious
        ];
  }

  void _updatePercentage(int index, double localY, double maxHeight) {
    final double rawPercentage = 1.0 - (localY / maxHeight);
    final double clampedPercentage = rawPercentage.clamp(0.0, 1.0);

    setState(() {
      _items[index].percentage = clampedPercentage;
    });

    if (widget.onChanged != null) {
      widget.onChanged!(_items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    const double barMaxHeight = 180.0;
    const double capsuleWidth =
        56.0; // Substantially wider capsules matching reference image

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1C24)
            : (themeState.hasMoodSelected
                  ? themeState.moodTheme.cardColor
                  : Colors.white),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C2834)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardBorder
                    : AppColors.lightCardBorder),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.emotionTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.emotionSubtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Row of interactive wide adjustable capsules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Interactive gesture detector for dragging/tapping
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      _updatePercentage(
                        index,
                        details.localPosition.dy,
                        barMaxHeight,
                      );
                    },
                    onTapDown: (details) {
                      _updatePercentage(
                        index,
                        details.localPosition.dy,
                        barMaxHeight,
                      );
                    },
                    child: Container(
                      height: barMaxHeight,
                      width: capsuleWidth,
                      color: Colors.transparent,
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Wide Background track capsule (matching reference track color)
                          Container(
                            width: capsuleWidth,
                            height: barMaxHeight,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black26
                                  : const Color(
                                      0xFFFBF8F4,
                                    ), // Soft warm cream track color
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          // Active capsule fill
                          Container(
                            width: capsuleWidth,
                            height: barMaxHeight * item.percentage,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              '${(item.percentage * 100).toInt()}%',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Text Label
                  Text(
                    _getLocalLabel(context, item.label),
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.text,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
