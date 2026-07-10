import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class DetectedObjectsList extends StatelessWidget {
  final List<Map<String, dynamic>> objects;

  const DetectedObjectsList({super.key, required this.objects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.center_focus_strong_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.visionResultObjectsTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: objects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final obj = objects[index];
              final String name = obj['name'];
              final double confidence = obj['confidence'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getLocalObjectName(context, name),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.visionConfidenceValue(
                          (confidence * 100).toInt().toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: confidence,
                      minHeight: 6,
                      backgroundColor: AppColors.lightBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getLocalObjectName(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    if (name == 'Laptop') return l10n.visionMockObjLaptop;
    if (name == 'Keyboard') return l10n.visionMockObjKeyboard;
    if (name == 'Coffee Mug') return l10n.visionMockObjCoffeeMug;
    if (name == 'Notebook') return l10n.visionMockObjNotebook;
    if (name == 'Pen') return l10n.visionMockObjPen;
    if (name == 'Houseplant') return l10n.visionMockObjHouseplant;
    if (name == 'Window Sill') return l10n.visionMockObjWindowSill;
    return name;
  }
}
