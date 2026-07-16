import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../chat_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/typing_indicator.dart';
import '../../../core/localization/generated/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? documentContext;

  const ChatScreen({super.key, this.documentContext});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  String? _activeDocumentContext;

  @override
  void initState() {
    super.initState();
    _activeDocumentContext = widget.documentContext;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Auto-scroll on new message or typing indicator toggle
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isTyping != next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1E1C24)
            : (themeState.hasMoodSelected
                  ? themeState.moodTheme.cardColor
                  : Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
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
        title: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.chatAuraCompanion,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, color: AppColors.success, size: 8),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.chatOnline,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white60
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark
                    ? const Color(0xFF2C2834)
                    : AppColors.lightCardBorder,
                width: 1.5,
              ),
            ),
            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
            onSelected: (value) {
              if (value == 'clear') {
                ref.read(chatProvider.notifier).clearChat();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat history cleared')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_rounded,
                      size: 18,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Clear Chat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            color: isDark ? const Color(0xFF2C2834) : AppColors.lightCardBorder,
            height: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Active Document Context Chip
          if (_activeDocumentContext != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_rounded,
                      size: 18,
                      color: accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q&A DOCUMENT CONTEXT',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _activeDocumentContext!,
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: accentColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _activeDocumentContext = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Message List View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount:
                  chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length) {
                  return const TypingIndicator();
                }
                final message = chatState.messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),

          // Suggestion Chips (floating above input box)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSuggestionChip(
                  context,
                  accentColor,
                  isDark,
                  themeState,
                  icon: _activeDocumentContext != null
                      ? Icons.notes_rounded
                      : Icons.code_rounded,
                  label: _activeDocumentContext != null
                      ? AppLocalizations.of(context)!.chatWhatGoal
                      : AppLocalizations.of(context)!.chatExplainCode,
                  onTap: () => ref
                      .read(chatProvider.notifier)
                      .sendMessage(
                        _activeDocumentContext != null
                            ? AppLocalizations.of(context)!.chatWhatGoal
                            : AppLocalizations.of(context)!.chatExplainCode,
                      ),
                ),
                const SizedBox(width: 12),
                _buildSuggestionChip(
                  context,
                  accentColor,
                  isDark,
                  themeState,
                  icon: _activeDocumentContext != null
                      ? Icons.access_time_rounded
                      : Icons.auto_fix_high_rounded,
                  label: _activeDocumentContext != null
                      ? AppLocalizations.of(context)!.chatSummarizeFile
                      : AppLocalizations.of(context)!.chatOptimizeScript,
                  onTap: () => ref
                      .read(chatProvider.notifier)
                      .sendMessage(
                        _activeDocumentContext != null
                            ? AppLocalizations.of(context)!.chatSummarizeFile
                            : AppLocalizations.of(context)!.chatOptimizeScript,
                      ),
                ),
              ],
            ),
          ),

          // Bottom Message Input Box
          SafeArea(
            top: false,
            child: MessageInput(
              onSend: (text) =>
                  ref.read(chatProvider.notifier).sendMessage(text),
              onAttachmentTap: () => _showAttachmentSheet(
                context,
                accentColor,
                isDark,
                themeState,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentSheet(
    BuildContext context,
    Color accentColor,
    bool isDark,
    ThemeState themeState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF1E1C24)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.cardColor
                : Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Attachment',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentItem(
                    context,
                    accentColor,
                    isDark,
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ref
                          .read(chatProvider.notifier)
                          .sendMessage(
                            'Analyze this physical workspace setup.',
                            imageUrl:
                                'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?q=80&w=400',
                          );
                    },
                  ),
                  _buildAttachmentItem(
                    context,
                    accentColor,
                    isDark,
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ref
                          .read(chatProvider.notifier)
                          .sendMessage(
                            'Explain this project plan diagram.',
                            imageUrl:
                                'https://images.unsplash.com/photo-1531403009284-440f080d1e12?q=80&w=400',
                          );
                    },
                  ),
                  _buildAttachmentItem(
                    context,
                    accentColor,
                    isDark,
                    icon: Icons.description_outlined,
                    label: 'Document',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ref
                          .read(chatProvider.notifier)
                          .sendMessage(
                            '📎 Attached: project_spec.pdf\nPlease review sections 1 and 2.',
                          );
                    },
                  ),
                  _buildAttachmentItem(
                    context,
                    accentColor,
                    isDark,
                    icon: Icons.mic_none_rounded,
                    label: 'Voice',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/voice');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(
    BuildContext context,
    Color accentColor,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    Color accentColor,
    bool isDark,
    ThemeState themeState, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
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
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
