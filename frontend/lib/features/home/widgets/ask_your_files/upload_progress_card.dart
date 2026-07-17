import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/generated/app_localizations.dart';

/// A progress card that animates to 85% quickly, then waits for [uploadFuture]
/// to complete before snapping to 100% and calling [onComplete].
///
/// This ensures the card never dismisses before the real upload is done.
class UploadProgressCard extends StatefulWidget {
  final String fileName;
  final VoidCallback onComplete;

  /// The actual upload + indexing future. The card pauses at 85% until
  /// this resolves (success or error).
  final Future<void>? uploadFuture;

  const UploadProgressCard({
    super.key,
    required this.fileName,
    required this.onComplete,
    this.uploadFuture,
  });

  @override
  State<UploadProgressCard> createState() => _UploadProgressCardState();
}

class _UploadProgressCardState extends State<UploadProgressCard> {
  int _currentStageIndex = 0;
  double _progressValue = 0.0;
  Timer? _timer;

  // Once we hit 85% we pause here and wait for the future.
  static const double _waitThreshold = 0.85;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _awaitUpload();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_progressValue < _waitThreshold) {
          _progressValue += 0.15;
          if (_progressValue >= _waitThreshold) {
            // Clamp to threshold and pause — wait for the real upload.
            _progressValue = _waitThreshold;
            timer.cancel();
          }
        }
        _updateStage();
      });
    });
  }

  void _awaitUpload() {
    final future = widget.uploadFuture;
    if (future == null) {
      // No future provided — fall back to old timer-only behaviour.
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _progressValue += 0.15;
          if (_progressValue >= 1.0) {
            _progressValue = 1.0;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) widget.onComplete();
            });
          }
          _updateStage();
        });
      });
      return;
    }

    future.then((_) {
      if (!mounted) return;
      // Upload succeeded — snap to 100% and dismiss.
      setState(() {
        _progressValue = 1.0;
        _currentStageIndex = 3;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onComplete();
      });
    }).catchError((Object err) {
      // Upload failed — onComplete is NOT called; the parent's catchError
      // already handles showing the error snackbar and clearing state.
      if (!mounted) return;
      widget.onComplete();
    });
  }

  void _updateStage() {
    if (_progressValue < 0.25) {
      _currentStageIndex = 0;
    } else if (_progressValue < 0.55) {
      _currentStageIndex = 1;
    } else if (_progressValue < _waitThreshold) {
      _currentStageIndex = 2;
    } else {
      _currentStageIndex = 3;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getLocalStage(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.documentsProgressUploading;
      case 1:
        return l10n.documentsProgressExtracting;
      case 2:
        return l10n.documentsProgressAnalyzing;
      case 3:
        return l10n.documentsProgressConnecting;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    // While waiting at 85%, show an indeterminate spinner to signal real work.
    final bool isWaiting = _progressValue >= _waitThreshold && _progressValue < 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    // null = indeterminate when waiting for backend
                    value: isWaiting ? null : _progressValue,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLocalStage(context, _currentStageIndex),
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isWaiting
                    ? '${(_progressValue * 100).toInt()}%'
                    : '${(_progressValue * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
