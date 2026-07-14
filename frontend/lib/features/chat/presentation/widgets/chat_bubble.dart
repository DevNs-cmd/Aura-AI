import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/chat_message.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/localized_dialog_action_bar.dart';
import '../../chat_provider.dart';

class ChatBubble extends ConsumerWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Color accentColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Message',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
        ),
        actions: [
          LocalizedDialogActionBar(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(chatProvider.notifier).deleteMessage(message.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(content: Text('Message deleted')),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContextSheet(
    BuildContext context,
    WidgetRef ref,
    Color accentColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.copy_rounded, color: accentColor),
                title: const Text(
                  'Copy Message Text',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied text to clipboard')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.share_rounded, color: accentColor),
                title: const Text(
                  'Share Message',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Simulated System Share API...'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete Message',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, ref, accentColor, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onLongPress: () => _showContextSheet(context, ref, accentColor, isDark),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              // Friendly companion face avatar
              _CompanionAvatar(accentColor: accentColor),
              const SizedBox(width: 12),
            ],

            // Bubble Body Wrapper
            Expanded(
              child: Column(
                crossAxisAlignment: message.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: min(MediaQuery.of(context).size.width * 0.7, 650),
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? accentColor
                          : (isDark
                                ? const Color(0xFF1E1C24)
                                : (themeState.hasMoodSelected
                                      ? themeState.moodTheme.cardColor
                                      : Colors.white)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: message.isUser
                            ? const Radius.circular(24)
                            : const Radius.circular(6),
                        bottomRight: message.isUser
                            ? const Radius.circular(6)
                            : const Radius.circular(24),
                      ),
                      border: message.isUser
                          ? null
                          : Border.all(
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
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // If there is an image attachment
                        if (message.imageUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              message.imageUrl!,
                              fit: BoxFit.cover,
                              height: 180,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 100,
                                    color: isDark
                                        ? const Color(0xFF1E1C24)
                                        : AppColors.lightBackground,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: isDark
                                          ? Colors.white24
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Message Content with inline parser
                        _renderMessageContent(context, accentColor, isDark),
                      ],
                    ),
                  ),

                  // Contextual Source Citation Card (if active in document context Q&A)
                  if (!message.isUser &&
                      (message.content.toLowerCase().contains("roadmap") ||
                          message.content.toLowerCase().contains("document") ||
                          message.content.toLowerCase().contains("file"))) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 12,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Source: Project Roadmap.pdf • Sec 2',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Timestamp & Quick Action Links (Only for AI bubbles)
                  if (!message.isUser) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(message.timestamp),
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Liked message')),
                              );
                            },
                            child: Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 14,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Regenerating...'),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderMessageContent(
    BuildContext context,
    Color accentColor,
    bool isDark,
  ) {
    final textColor = message.isUser
        ? Colors.white
        : (isDark ? Colors.white : AppColors.lightTextPrimary);
    final content = message.content;

    // Detect if content contains code blocks
    if (content.contains('```')) {
      final List<Widget> segments = [];
      final parts = content.split('```');

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i % 2 == 0) {
          // Regular text part
          if (part.trim().isNotEmpty) {
            segments.add(
              Text(
                part.trim(),
                style: GoogleFonts.quicksand(
                  color: textColor,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
        } else {
          // Code block part
          final lines = part.split('\n');
          String lang = 'code';
          String codeBody = part;

          if (lines.isNotEmpty && lines.first.trim().isNotEmpty) {
            lang = lines.first.trim();
            codeBody = lines.sublist(1).join('\n').trim();
          }

          segments.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141318)
                      : const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code Block Header bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F0E12)
                            : const Color(0xFF141418),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: codeBody));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied code to clipboard'),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Copy',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Code content body
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          codeBody,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontFamily: 'Courier',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: segments,
      );
    }

    // Default basic text widget
    return Text(
      content,
      style: GoogleFonts.quicksand(
        color: textColor,
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CompanionAvatar extends StatelessWidget {
  final Color accentColor;
  const _CompanionAvatar({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
