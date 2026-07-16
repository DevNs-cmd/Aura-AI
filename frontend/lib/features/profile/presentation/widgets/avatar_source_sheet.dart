import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class AvatarSourceSheet extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final Function(ImageSource) onSourceSelected;

  const AvatarSourceSheet({
    super.key,
    required this.accentColor,
    required this.isDark,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.profileChoosePic,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: accentColor),
                title: Text(
                  l10n.profileTakePhoto,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.camera);
                },
              ),
              Divider(
                color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: accentColor),
                title: Text(
                  l10n.profileChooseGallery,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
              Divider(
                color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
              ),
              ListTile(
                leading: const Icon(
                  Icons.close_rounded,
                  color: Colors.redAccent,
                ),
                title: Text(
                  l10n.profileCancel,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
