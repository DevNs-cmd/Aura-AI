import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../vision_provider.dart';

// Reusable custom painters for the FOCUSED Vision screen UI
class _PortalBracketsPainter extends CustomPainter {
  final Color color;
  _PortalBracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double l = 20.0; // length of bracket arm
    final double gap = 4.0; // padding from border

    // Top-Left
    canvas.drawLine(Offset(gap, gap), Offset(gap + l, gap), paint);
    canvas.drawLine(Offset(gap, gap), Offset(gap, gap + l), paint);

    // Top-Right
    canvas.drawLine(
      Offset(size.width - gap, gap),
      Offset(size.width - gap - l, gap),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - gap, gap),
      Offset(size.width - gap, gap + l),
      paint,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(gap, size.height - gap),
      Offset(gap + l, size.height - gap),
      paint,
    );
    canvas.drawLine(
      Offset(gap, size.height - gap),
      Offset(gap, size.height - gap - l),
      paint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(size.width - gap, size.height - gap),
      Offset(size.width - gap - l, size.height - gap),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - gap, size.height - gap),
      Offset(size.width - gap, size.height - gap - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PortalBracketsPainter oldDelegate) => false;
}

class _AuraEyePainter extends CustomPainter {
  final Color color;
  _AuraEyePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    final eyePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Eye outline path (arcs)
    final eyePath = Path();
    eyePath.moveTo(cx - w * 0.35, cy);
    eyePath.quadraticBezierTo(cx, cy - h * 0.3, cx + w * 0.35, cy);
    eyePath.quadraticBezierTo(cx, cy + h * 0.3, cx - w * 0.35, cy);
    eyePath.close();
    canvas.drawPath(eyePath, eyePaint);

    // Pupil circle
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.12,
      eyePaint..style = PaintingStyle.fill,
    );

    // Inner Sparkle (white 4-point star)
    final sparkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final sparkPath = Path();
    final double r = w * 0.06;
    sparkPath.moveTo(cx, cy - r);
    sparkPath.quadraticBezierTo(cx, cy, cx + r, cy);
    sparkPath.quadraticBezierTo(cx, cy, cx, cy + r);
    sparkPath.quadraticBezierTo(cx, cy, cx - r, cy);
    sparkPath.quadraticBezierTo(cx, cy, cx, cy - r);
    sparkPath.close();
    canvas.drawPath(sparkPath, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _AuraEyePainter oldDelegate) => false;
}

class VisionAnalysisScreen extends ConsumerStatefulWidget {
  const VisionAnalysisScreen({super.key});

  @override
  ConsumerState<VisionAnalysisScreen> createState() =>
      _VisionAnalysisScreenState();
}

class _VisionAnalysisScreenState extends ConsumerState<VisionAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  // Local state properties for custom presentation layer
  String _selectedMode = 'Understand Scene';
  int _activeResultTab = 0; // 0: Scene, 1: Objects, 2: Text, 3: Context

  // Mock data representing recent sightings history items
  final List<Map<String, dynamic>> _mockRecentSightings = [
    {
      'imagePath':
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=256&h=256&fit=crop',
      'title': 'Office Desk Setup',
      'mode': 'Understand Scene',
      'detectedObjects': [
        {'name': 'Laptop', 'confidence': 0.98},
        {'name': 'Keyboard', 'confidence': 0.95},
        {'name': 'Coffee Mug', 'confidence': 0.89},
      ],
      'ocrText':
          'PLAN:\n- Launch v1.0 by Friday morning!\n- Schedule Team Sync at 10 AM\n- Buy coffee beans',
      'scene':
          'I see a modern and clean office desk setup. There is a silver laptop open on the desk, a mechanical keyboard, and a dark ceramic coffee mug. The desk has a light wooden texture.',
      'context':
          'This setup is ideal for software development or writing. The planner notes indicate a high-priority product launch deadline approaching this Friday.',
      'timestamp': '2h ago',
    },
    {
      'imagePath':
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?q=80&w=256&h=256&fit=crop',
      'title': 'Handwritten Notes',
      'mode': 'Read Text',
      'detectedObjects': [
        {'name': 'Notebook', 'confidence': 0.99},
        {'name': 'Pen', 'confidence': 0.93},
      ],
      'ocrText':
          'Reflections on Growth:\nChange is constant. Focus on building habits, not just achieving goals. Take small steps daily.',
      'scene':
          'I see a handwritten notebook page open on a wooden table with a pen lying next to it.',
      'context':
          'The text captures personal development ideas on habits. This fits well with your Journal reflecting features.',
      'timestamp': 'Yesterday',
    },
    {
      'imagePath':
          'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?q=80&w=256&h=256&fit=crop',
      'title': 'Plant on Window Sill',
      'mode': 'Identify Objects',
      'detectedObjects': [
        {'name': 'Houseplant', 'confidence': 0.97},
        {'name': 'Window Sill', 'confidence': 0.92},
      ],
      'ocrText': 'PLANT CARE GUIDE',
      'scene':
          'I see a green potted houseplant sitting on a white window sill. Sunlight is coming through the glass window pane.',
      'context':
          'Natural light and plants can boost productivity and mood. Fits well with your Calm mood theme.',
      'timestamp': '3 days ago',
    },
  ];

  // Rotation messages for scanning state
  final List<String> _scanMessageKeys = [
    'visionScanLooking',
    'visionScanFinding',
    'visionScanReading',
    'visionScanConnecting',
    'visionScanPreparing',
  ];
  int _currentMessageIndex = 0;

  // Keep track of which mock sighting is selected
  Map<String, dynamic>? _selectedMockSighting;

  // Translation mapping helper methods
  String _getLocalSightingTitle(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    if (title == 'Office Desk Setup') return l10n.visionMockTitleDesk;
    if (title == 'Handwritten Notes') return l10n.visionMockTitleNotes;
    if (title == 'Plant on Window Sill') return l10n.visionMockTitlePlant;
    return title;
  }

  String _getLocalModeName(BuildContext context, String mode) {
    final l10n = AppLocalizations.of(context)!;
    if (mode == 'Understand Scene') return l10n.visionModeUnderstandScene;
    if (mode == 'Read Text') return l10n.visionModeReadText;
    if (mode == 'Identify Objects') return l10n.visionModeIdentifyObjects;
    if (mode == 'Describe Image') return l10n.visionModeDescribeImage;
    if (mode == 'Find Details') return l10n.visionModeFindDetails;
    return mode;
  }

  String _getLocalSceneText(BuildContext context, String scene) {
    final l10n = AppLocalizations.of(context)!;
    if (scene.startsWith('I see a modern and clean office desk setup'))
      return l10n.visionMockSceneDesk;
    if (scene.startsWith('I see a handwritten notebook page open'))
      return l10n.visionMockSceneNotes;
    if (scene.startsWith('I see a green potted houseplant'))
      return l10n.visionMockScenePlant;
    return scene;
  }

  String _getLocalContextText(BuildContext context, String contextText) {
    final l10n = AppLocalizations.of(context)!;
    if (contextText.startsWith('This setup is ideal'))
      return l10n.visionMockContextDesk;
    if (contextText.startsWith('The text captures'))
      return l10n.visionMockContextNotes;
    if (contextText.startsWith('Natural light and plants'))
      return l10n.visionMockContextPlant;
    return contextText;
  }

  String _getLocalOcrText(BuildContext context, String ocr) {
    final l10n = AppLocalizations.of(context)!;
    if (ocr.startsWith('PLAN:')) return l10n.visionMockOcrDesk;
    if (ocr.startsWith('Reflections on Growth:'))
      return l10n.visionMockOcrNotes;
    if (ocr.startsWith('PLANT CARE GUIDE')) return l10n.visionMockOcrPlant;
    return ocr;
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

  String _getLocalScanMessage(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'visionScanLooking':
        return l10n.visionScanLooking;
      case 'visionScanFinding':
        return l10n.visionScanFinding;
      case 'visionScanReading':
        return l10n.visionScanReading;
      case 'visionScanConnecting':
        return l10n.visionScanConnecting;
      case 'visionScanPreparing':
        return l10n.visionScanPreparing;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _triggerScan() {
    _selectedMockSighting = null;
    ref.read(visionProvider.notifier).selectImage('camera');
    _rotateScanMessages();
  }

  void _rotateScanMessages() async {
    _currentMessageIndex = 0;
    while (ref.read(visionProvider).isScanning) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted && ref.read(visionProvider).isScanning) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _scanMessageKeys.length;
        });
      }
    }
  }

  void _selectMockSighting(Map<String, dynamic> sighting) {
    setState(() {
      _selectedMockSighting = sighting;
      _selectedMode = sighting['mode'];
      _activeResultTab = 0;
    });
    // Sync to mock provider state so standard handlers work
    ref.read(visionProvider.notifier).selectImage('mock');
  }

  @override
  Widget build(BuildContext context) {
    final visionState = ref.watch(visionProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Computed values depending on selected mock vs default provider mocks
    final hasImage =
        _selectedMockSighting != null || visionState.imagePath != null;
    final currentImagePath = _selectedMockSighting != null
        ? _selectedMockSighting!['imagePath'] as String
        : visionState.imagePath;
    final isScanning = _selectedMockSighting == null && visionState.isScanning;
    final showResults =
        _selectedMockSighting != null || visionState.showResults;

    // Get specific result components
    final sceneText = _selectedMockSighting != null
        ? _getLocalSceneText(context, _selectedMockSighting!['scene'] as String)
        : AppLocalizations.of(context)!.visionMockSceneDesk;
    final detectedObjects = _selectedMockSighting != null
        ? _selectedMockSighting!['detectedObjects']
              as List<Map<String, dynamic>>
        : visionState.detectedObjects;
    final ocrText = _selectedMockSighting != null
        ? (_selectedMockSighting!['ocrText'] != null
              ? _getLocalOcrText(
                  context,
                  _selectedMockSighting!['ocrText'] as String,
                )
              : null)
        : (visionState.ocrText != null
              ? _getLocalOcrText(context, visionState.ocrText!)
              : null);
    final contextText = _selectedMockSighting != null
        ? _getLocalContextText(
            context,
            _selectedMockSighting!['context'] as String,
          )
        : AppLocalizations.of(context)!.visionMockContextDesk;

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.visionTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.visionHistorySnackbar,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.visionSubtitle,
                style: GoogleFonts.quicksand(
                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 1. VISION HERO PORTAL
              _buildVisionPortal(
                isDark,
                accentColor,
                hasImage,
                currentImagePath,
                isScanning,
              ),

              const SizedBox(height: 24),

              // 2. PRIMARY ACTIONS (If idle)
              if (!hasImage && !isScanning) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        isDark: isDark,
                        accentColor: accentColor,
                        icon: Icons.camera_enhance_rounded,
                        title: AppLocalizations.of(
                          context,
                        )!.visionActionCameraTitle,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.visionActionCameraSubtitle,
                        onTap: _triggerScan,
                        themeState: themeState,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        isDark: isDark,
                        accentColor: accentColor,
                        icon: Icons.photo_library_rounded,
                        title: AppLocalizations.of(
                          context,
                        )!.visionActionLibraryTitle,
                        subtitle: AppLocalizations.of(
                          context,
                        )!.visionActionLibrarySubtitle,
                        onTap: _triggerScan,
                        themeState: themeState,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 3. QUICK VISION MODES
                _buildQuickModes(isDark, accentColor, themeState),
                const SizedBox(height: 28),

                // 4. RECENT VISION SECTION ("Recent Sightings")
                _buildRecentSightings(isDark, themeState),
              ] else if (isScanning) ...[
                // Loading / Scanning State below portal
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Text(
                        _getLocalScanMessage(
                          context,
                          _scanMessageKeys[_currentMessageIndex],
                        ),
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (showResults) ...[
                // Clear Image Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedMockSighting = null;
                      });
                      ref.read(visionProvider.notifier).clearImage();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: accentColor,
                      size: 18,
                    ),
                    label: Text(
                      'Scan Another',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. RESULT EXPERIENCE TABS & CONTENT
                _buildResultTabs(isDark, accentColor, themeState),
                const SizedBox(height: 16),
                _buildTabContent(
                  isDark,
                  accentColor,
                  themeState,
                  sceneText,
                  detectedObjects,
                  ocrText,
                  contextText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Large Immersive Vision Portal Widget
  Widget _buildVisionPortal(
    bool isDark,
    Color accentColor,
    bool hasImage,
    String? imagePath,
    bool isScanning,
  ) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C24) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grid Background Texture (Idle)
              if (!hasImage && !isScanning)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridBackgroundPainter(isDark: isDark),
                  ),
                ),

              // Image display
              if (hasImage)
                Positioned.fill(
                  child: Image.network(imagePath!, fit: BoxFit.cover),
                ),

              // Visual overlays
              Positioned.fill(
                child: CustomPaint(
                  painter: _PortalBracketsPainter(
                    color: isScanning
                        ? accentColor
                        : accentColor.withValues(alpha: 0.5),
                  ),
                ),
              ),

              // Scanning Sweeper Line Animation
              if (isScanning || hasImage)
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    final double topPercent = _scanController.value;
                    return Positioned(
                      top: topPercent * 250,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.7),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              accentColor,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Central eye symbol (Idle Only)
              if (!hasImage && !isScanning)
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CustomPaint(
                    painter: _AuraEyePainter(color: accentColor),
                  ),
                ),

              // Status messages overlay
              if (!hasImage && !isScanning)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.visionReadyTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.visionReadyDesc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Scanning Overlay Blur
              if (isScanning)
                Container(
                  color: accentColor.withValues(alpha: 0.08),
                  child: const Center(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(strokeWidth: 3.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Clickable Action Cards
  Widget _buildActionCard({
    required bool isDark,
    required Color accentColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeState themeState,
  }) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1C24)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardColor
                    : Colors.white),
          borderRadius: BorderRadius.circular(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.quicksand(
                fontSize: 10,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Modes Horizontal Scroll Section
  Widget _buildQuickModes(
    bool isDark,
    Color accentColor,
    ThemeState themeState,
  ) {
    final List<Map<String, dynamic>> modes = [
      {'name': 'Understand Scene', 'icon': Icons.visibility_outlined},
      {'name': 'Read Text', 'icon': Icons.text_fields_outlined},
      {'name': 'Identify Objects', 'icon': Icons.category_outlined},
      {'name': 'Describe Image', 'icon': Icons.description_outlined},
      {'name': 'Find Details', 'icon': Icons.zoom_in_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.visionQuickModesTitle,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: modes.map((m) {
              final isSelected = _selectedMode == m['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: BouncingWidget(
                  onTap: () {
                    setState(() {
                      _selectedMode = m['name'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor
                          : (isDark
                                ? const Color(0xFF1E1C24)
                                : (themeState.hasMoodSelected
                                      ? themeState.moodTheme.cardColor
                                      : Colors.white)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : (isDark
                                  ? const Color(0xFF2C2834)
                                  : (themeState.hasMoodSelected
                                        ? themeState.moodTheme.cardBorder
                                        : AppColors.lightCardBorder)),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          m['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getLocalModeName(context, m['name'] as String),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white70
                                      : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Recent Sightings horizontal thumbnails List
  Widget _buildRecentSightings(bool isDark, ThemeState themeState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.visionRecentSightingsTitle,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _mockRecentSightings.map((sighting) {
              return Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: BouncingWidget(
                  onTap: () => _selectMockSighting(sighting),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1C24)
                          : (themeState.hasMoodSelected
                                ? themeState.moodTheme.cardColor
                                : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2C2834)
                            : (themeState.hasMoodSelected
                                  ? themeState.moodTheme.cardBorder
                                  : AppColors.lightCardBorder),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clip Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            sighting['imagePath'] as String,
                            width: 140,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocalSightingTitle(
                                  context,
                                  sighting['title'] as String,
                                ),
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _getLocalModeName(
                                  context,
                                  sighting['mode'] as String,
                                ),
                                style: GoogleFonts.quicksand(
                                  fontSize: 9,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Result Segmented Tab Row
  Widget _buildResultTabs(
    bool isDark,
    Color accentColor,
    ThemeState themeState,
  ) {
    final List<String> tabs = [
      AppLocalizations.of(context)!.visionTabScene,
      AppLocalizations.of(context)!.visionTabObjects,
      AppLocalizations.of(context)!.visionTabText,
      AppLocalizations.of(context)!.visionTabContext,
    ];
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : AppColors.blueWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == _activeResultTab;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: BouncingWidget(
                onTap: () {
                  setState(() {
                    _activeResultTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF2C2834) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? accentColor
                          : (isDark
                                ? Colors.white60
                                : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Content rendering based on selected Tab
  Widget _buildTabContent(
    bool isDark,
    Color accentColor,
    ThemeState themeState,
    String sceneText,
    List<Map<String, dynamic>> detectedObjects,
    String? ocrText,
    String contextText,
  ) {
    switch (_activeResultTab) {
      case 0:
        return _buildCardWrapper(
          isDark: isDark,
          themeState: themeState,
          title: AppLocalizations.of(context)!.visionResultSceneTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sceneText,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomActionDrawer(isDark, accentColor),
            ],
          ),
        );
      case 1:
        return _buildCardWrapper(
          isDark: isDark,
          themeState: themeState,
          title: AppLocalizations.of(context)!.visionResultObjectsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...detectedObjects.map((obj) {
                final double progress = obj['confidence'] as double;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getLocalObjectName(context, obj['name'] as String),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.white10
                              : AppColors.lightCardBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              _buildBottomActionDrawer(isDark, accentColor),
            ],
          ),
        );
      case 2:
        return _buildCardWrapper(
          isDark: isDark,
          themeState: themeState,
          title: AppLocalizations.of(context)!.visionResultTextTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ocrText != null && ocrText.trim().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141318)
                        : AppColors.blueWhite,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    ocrText,
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white70
                          : AppColors.lightTextPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ocrText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.visionOcrCopied,
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          AppLocalizations.of(context)!.visionButtonCopy,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.visionTextShared,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: Text(
                          AppLocalizations.of(context)!.visionButtonShare,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    AppLocalizations.of(context)!.visionNoTextDetected,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _buildBottomActionDrawer(isDark, accentColor),
            ],
          ),
        );
      case 3:
        return _buildCardWrapper(
          isDark: isDark,
          themeState: themeState,
          title: AppLocalizations.of(context)!.visionResultContextTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contextText,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomActionDrawer(isDark, accentColor),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  // Wrapper for Result Cards
  Widget _buildCardWrapper({
    required bool isDark,
    required ThemeState themeState,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1C24)
            : (themeState.hasMoodSelected
                  ? themeState.moodTheme.cardColor
                  : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C2834)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardBorder
                    : AppColors.lightCardBorder),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: themeState.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Actions Drawer
  Widget _buildBottomActionDrawer(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: isDark ? Colors.white10 : AppColors.lightCardBorder),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.visionDrawerTitle,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDrawerButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: AppLocalizations.of(context)!.visionDrawerBtnAsk,
                onTap: () {
                  context.push('/chat');
                },
                accentColor: accentColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDrawerButton(
                icon: Icons.psychology_outlined,
                label: AppLocalizations.of(context)!.visionDrawerBtnSave,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.visionSavedToMemory,
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                accentColor: accentColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDrawerButton(
                icon: Icons.menu_book_outlined,
                label: AppLocalizations.of(context)!.visionDrawerBtnLog,
                onTap: () {
                  context.push('/create-journal');
                },
                accentColor: accentColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accentColor,
    required bool isDark,
  }) {
    return BouncingWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2834) : AppColors.blueWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppColors.oceanNavy,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Background painter representing a high fidelity technical grid overlay
class _GridBackgroundPainter extends CustomPainter {
  final bool isDark;
  _GridBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double step = 24.0;
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.015)
      ..strokeWidth = 1.0;

    // Vertical grid lines
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Horizontal grid lines
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) => false;
}
