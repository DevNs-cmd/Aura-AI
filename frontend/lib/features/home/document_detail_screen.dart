import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/localization/generated/app_localizations.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String name;
  final String size;
  final String type;

  const DocumentDetailScreen({
    super.key,
    required this.name,
    required this.size,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    Color fileColor = Colors.grey;
    IconData fileIcon = Icons.text_snippet_rounded;

    if (type.toUpperCase() == 'PDF') {
      fileColor = Colors.redAccent;
      fileIcon = Icons.picture_as_pdf_rounded;
    } else if (type.toUpperCase() == 'DOC' || type.toUpperCase() == 'DOCX') {
      fileColor = const Color(0xFF7C8CFF);
      fileIcon = Icons.description_rounded;
    } else if (type.toUpperCase() == 'TXT') {
      fileColor = Colors.amber;
      fileIcon = Icons.notes_rounded;
    }

    // Dynamic semantic takeaways based on filename!
    List<String> takeaways = [
      "Initial architectural layouts, dependencies mapping, and routing endpoints.",
      "Identifies standard specifications, UI assets scaling constraints, and lints policies.",
      "Contains details of local preferences syncing states with shared device memory.",
    ];

    if (name.contains("Roadmap")) {
      takeaways = [
        "Milestones timeline stretching from baseline discovery to final verification phases.",
        "Highlights key deliverables for Chat interface elements and locale translation sheets.",
        "Identifies resource dependencies, test suite execution constraints, and handoff criteria.",
      ];
    } else if (name.contains("Guide")) {
      takeaways = [
        "Standard conventions for writing Riverpod controllers and binding GoRouter scopes.",
        "Details layout scaling, custom painters usage, and theme colors mapping constraints.",
        "Comprehensive walkthrough of setting up mock classes inside testing suites.",
      ];
    }

    final List<String> keyConcepts = name.contains("Roadmap")
        ? ["Timeline", "Deliverables", "Phases", "Handoff"]
        : name.contains("Guide")
        ? ["Riverpod", "GoRouter", "Theme", "Testing"]
        : ["Notes", "Draft", "Concepts", "Reference"];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.documentsDetailTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Document Hero Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C2834)
                        : AppColors.lightCardBorder,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: fileColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(fileIcon, color: fileColor, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.documentsOcrReady(size, type),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. What Aura Found Section
              Text(
                AppLocalizations.of(context)!.documentsDetailWhatAuraFound,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.documentsDetailTakeaways,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...takeaways.map(
                      (takeaway) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                Icons.lens_rounded,
                                size: 5,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                takeaway,
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.lightTextPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24, thickness: 1),
                    Text(
                      AppLocalizations.of(context)!.documentsDetailKeyConcepts,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: keyConcepts
                          .map(
                            (concept) => Chip(
                              label: Text(
                                concept,
                                style: GoogleFonts.quicksand(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 0,
                              ),
                              backgroundColor: accentColor.withValues(
                                alpha: 0.08,
                              ),
                              side: BorderSide(
                                color: accentColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Raw Content Preview Panel
              Text(
                AppLocalizations.of(context)!.documentsDetailPreview,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C2834)
                        : AppColors.lightCardBorder,
                    width: 1.5,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    AppLocalizations.of(context)!.documentsDetailPreviewLines +
                        AppLocalizations.of(
                          context,
                        )!.documentsDetailPreviewLorem,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Action CTA Button
              PrimaryButton(
                text: AppLocalizations.of(context)!.documentsDetailBtnAsk,
                backgroundColor: accentColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.documentsDetailStartingChat(name),
                      ),
                    ),
                  );
                  context.push('/chat');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
