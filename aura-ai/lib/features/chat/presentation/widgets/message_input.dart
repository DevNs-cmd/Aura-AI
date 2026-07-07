import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class MessageInput extends ConsumerStatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttachmentTap;

  const MessageInput({super.key, required this.onSend, this.onAttachmentTap});

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final _controller = TextEditingController();
  bool _isWriting = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_textListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_textListener);
    _controller.dispose();
    super.dispose();
  }

  void _textListener() {
    final text = _controller.text.trim();
    if (text.isNotEmpty != _isWriting) {
      setState(() {
        _isWriting = text.isNotEmpty;
      });
    }
  }

  void _submitMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      if (_showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    }
  }

  Widget _buildEmojiPicker(Color accentColor, bool isDark) {
    final emojis = [
      '😊',
      '😔',
      '😌',
      '😴',
      '🤩',
      '🌱',
      '🌙',
      '💻',
      '💡',
      '📅',
      '🚀',
      '🧠',
      '👍',
      '✨',
      '🎉',
      '❤️',
      '🔥',
      '😇',
      '🤔',
      '💬',
      '👀',
      '💪',
      '🎨',
      '✈️',
    ];
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: _showEmojiPicker
          ? Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF2D2834)
                        : AppColors.lightCardBorder,
                    width: 1.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: emojis.length,
                itemBuilder: (context, index) {
                  final emoji = emojis[index];
                  return GestureDetector(
                    onTap: () {
                      final text = _controller.text;
                      final selection = _controller.selection;
                      final start = selection.start >= 0
                          ? selection.start
                          : text.length;
                      final end = selection.end >= 0
                          ? selection.end
                          : text.length;

                      final newText = text.replaceRange(start, end, emoji);
                      _controller.text = newText;
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: start + emoji.length),
                      );
                    },
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Row(
            children: [
              // Attachment button
              GestureDetector(
                onTap: widget.onAttachmentTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1C24)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2834)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Message input field
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2834)
                          : AppColors.lightCardBorder,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _showEmojiPicker
                              ? Icons.keyboard_rounded
                              : Icons.sentiment_satisfied_alt_rounded,
                          color: isDark
                              ? Colors.white38
                              : AppColors.lightTextTertiary,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submitMessage(),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.chatMessageHint,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                            hintStyle: GoogleFonts.quicksand(
                              color: isDark
                                  ? Colors.white30
                                  : AppColors.lightTextTertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Send button
              GestureDetector(
                onTap: _submitMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isWriting
                        ? accentColor
                        : accentColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildEmojiPicker(accentColor, isDark),
      ],
    );
  }
}
