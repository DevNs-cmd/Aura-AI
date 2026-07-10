import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../models/notification_item.dart';
import '../notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionPrompt();
  }

  Future<void> _checkPermissionPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown =
        prefs.getBool('notification_permission_shown') ?? false;
    if (!alreadyShown) {
      if (mounted) {
        _showPermissionDialog(context, prefs);
      }
    }
  }

  void _showPermissionDialog(BuildContext context, SharedPreferences prefs) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeState = ref.read(themeProvider);
      final accentColor = themeState.accentColor;
      final isDark = themeState.isDarkMode;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
          title: Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Enable Notifications',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Aura AI would like to send you notifications for your goal progress check-ins, journal writing prompts, and daily companion insights.',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool('notification_permission_shown', true);
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications disabled')),
                  );
                }
              },
              child: Text(
                'Don\'t Allow',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await prefs.setBool('notification_permission_shown', true);
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications enabled!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(
                'Allow',
                style: GoogleFonts.outfit(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Journal':
        return Icons.edit_note_rounded;
      case 'Goals':
        return Icons.track_changes_rounded;
      case 'AI Suggestions':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getCategoryColor(String cat, Color accentColor) {
    switch (cat) {
      case 'Journal':
        return accentColor;
      case 'Goals':
        return const Color(0xFF7C8CFF);
      case 'AI Suggestions':
        return const Color(0xFF57C7D4);
      default:
        return AppColors.lightTextSecondary;
    }
  }

  Color _getPriorityColor(String prio, Color accentColor) {
    switch (prio) {
      case 'high':
        return const Color(0xFFFF7A45); // Warm Sunset
      case 'medium':
        return const Color(0xFF7ED957); // Green
      case 'low':
        return accentColor;
      default:
        return AppColors.lightTextSecondary;
    }
  }

  String _getTimeStr(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours == 0) {
      return 'Just now';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationsProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Grouping logic: Today vs Yesterday
    final today = <NotificationItem>[];
    final yesterday = <NotificationItem>[];

    final now = DateTime.now();
    for (final n in notifState.notifications) {
      final diffDays = now.difference(n.timestamp).inDays;
      if (diffDays == 0) {
        today.add(n);
      } else {
        yesterday.add(n);
      }
    }

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
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (notifState.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).readAll(),
              child: Text(
                'Read All',
                style: GoogleFonts.outfit(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: notifState.notifications.isEmpty
            ? _buildEmptyState(isDark)
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today Group
                    if (today.isNotEmpty) ...[
                      _buildSectionHeader('Today', isDark),
                      const SizedBox(height: 14),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: today.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildNotificationCard(
                          context,
                          ref,
                          today[index],
                          isDark,
                          accentColor,
                          themeState,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Yesterday / Earlier Group
                    if (yesterday.isNotEmpty) ...[
                      _buildSectionHeader('Yesterday & Earlier', isDark),
                      const SizedBox(height: 14),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: yesterday.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildNotificationCard(
                          context,
                          ref,
                          yesterday[index],
                          isDark,
                          accentColor,
                          themeState,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
    bool isDark,
    Color accentColor,
    ThemeState themeState,
  ) {
    final catColor = _getCategoryColor(item.category, accentColor);
    final catIcon = _getCategoryIcon(item.category);
    final timeStr = _getTimeStr(item.timestamp);
    final prioColor = _getPriorityColor(item.priority, accentColor);

    final cardBgColor = item.isRead
        ? (isDark
              ? const Color(0xFF1E1C24)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardColor
                    : Colors.white))
        : accentColor.withValues(alpha: isDark ? 0.08 : 0.03);
    final cardBorderColor = item.isRead
        ? (isDark
              ? const Color(0xFF2C2834)
              : (themeState.hasMoodSelected
                    ? themeState.moodTheme.cardBorder
                    : AppColors.lightCardBorder))
        : accentColor.withValues(alpha: 0.25);
    final titleTextColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final descTextColor = isDark
        ? Colors.white70
        : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () {
        if (!item.isRead) {
          ref.read(notificationsProvider.notifier).readNotification(item.id);
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24), // Consistent rounded corners
          border: Border.all(color: cardBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread accent dot badge indicator on side
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(top: 14, right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),

            // Category Avatar circle icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(catIcon, color: catColor, size: 18),
            ),
            const SizedBox(width: 14),

            // Text titles and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: titleTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: descTextColor,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Delete & Priority indicator column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: prioColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.priority,
                    style: GoogleFonts.outfit(
                      color: prioColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? Colors.white30
                        : AppColors.lightTextTertiary,
                    size: 16,
                  ),
                  onPressed: () =>
                      ref.read(notificationsProvider.notifier).dismiss(item.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: isDark ? Colors.white24 : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 18),
          Text(
            'All caught up!',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No new notifications.',
            style: GoogleFonts.quicksand(
              color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
