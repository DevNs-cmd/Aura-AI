import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../chat_sessions_provider.dart';

class ChatSidebar extends ConsumerWidget {
  final bool isDrawer;

  const ChatSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(chatSessionsProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    final locale = Localizations.localeOf(context).languageCode;
    String searchHint = 'Search chats...';
    String newChatBtn = 'New Chat';
    String deleteConfirmTitle = 'Delete Chat';
    String deleteConfirmDesc = 'Are you sure you want to delete this chat?';
    String renameTitle = 'Rename Chat';
    String cancelLabel = 'Cancel';
    String deleteLabel = 'Delete';
    String saveLabel = 'Save';

    switch (locale) {
      case 'es':
        searchHint = 'Buscar chats...';
        newChatBtn = 'Nuevo chat';
        deleteConfirmTitle = 'Eliminar chat';
        deleteConfirmDesc = '¿Estás seguro de que deseas eliminar este chat?';
        renameTitle = 'Renombrar chat';
        cancelLabel = 'Cancelar';
        deleteLabel = 'Eliminar';
        saveLabel = 'Guardar';
        break;
      case 'hi':
        searchHint = 'चैट खोजें...';
        newChatBtn = 'नई चैट';
        deleteConfirmTitle = 'चैट हटाएं';
        deleteConfirmDesc = 'क्या आप वाकई इस चैट को हटाना चाहते हैं?';
        renameTitle = 'नाम बदलें';
        cancelLabel = 'रद्द करें';
        deleteLabel = 'हटाएं';
        saveLabel = 'सहेजें';
        break;
      case 'fr':
        searchHint = 'Rechercher des chats...';
        newChatBtn = 'Nouveau chat';
        deleteConfirmTitle = 'Supprimer le chat';
        deleteConfirmDesc = 'Êtes-vous sûr de vouloir supprimer ce chat ?';
        renameTitle = 'Renommer le chat';
        cancelLabel = 'Annuler';
        deleteLabel = 'Supprimer';
        saveLabel = 'Enregistrer';
        break;
      case 'de':
        searchHint = 'Chats durchsuchen...';
        newChatBtn = 'Neuer Chat';
        deleteConfirmTitle = 'Chat löschen';
        deleteConfirmDesc =
            'Sind Sie sicher, dass Sie diesen Chat löschen möchten?';
        renameTitle = 'Chat umbenennen';
        cancelLabel = 'Abbrechen';
        deleteLabel = 'Löschen';
        saveLabel = 'Speichern';
        break;
    }

    final sidebarColor = isDark
        ? const Color(0xFF1E1C24)
        : (themeState.hasMoodSelected
              ? themeState.moodTheme.cardColor
              : Colors.white);

    final borderColor = isDark
        ? const Color(0xFF2C2834)
        : (themeState.hasMoodSelected
              ? themeState.moodTheme.cardBorder
              : AppColors.lightCardBorder);

    return Container(
      width: isDrawer ? double.infinity : 280,
      decoration: BoxDecoration(
        color: sidebarColor,
        border: isDrawer
            ? null
            : Border(right: BorderSide(color: borderColor, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Sidebar Header with "New Chat" Action
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                final locale = Localizations.localeOf(context).languageCode;
                String defaultTitle = 'New Conversation';
                if (locale == 'es') defaultTitle = 'Nueva conversación';
                if (locale == 'hi') defaultTitle = 'नई बातचीत';
                if (locale == 'fr') defaultTitle = 'Nouvelle conversation';
                if (locale == 'de') defaultTitle = 'Neue Konversation';

                ref
                    .read(chatSessionsProvider.notifier)
                    .createSession(
                      '$defaultTitle ${sessionState.sessions.length + 1}',
                    );
                if (isDrawer) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                newChatBtn,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),

          // 2. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2834) : AppColors.blueWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? Colors.white30
                        : AppColors.lightTextSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        ref
                            .read(chatSessionsProvider.notifier)
                            .setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: GoogleFonts.quicksand(
                          color: isDark
                              ? Colors.white30
                              : AppColors.lightTextTertiary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
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

          const SizedBox(height: 12),

          // 3. Scrollable list of sessions
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: sessionState.filteredSessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final session = sessionState.filteredSessions[index];
                final isSelected = session.id == sessionState.activeSessionId;

                return InkWell(
                  onTap: () {
                    ref
                        .read(chatSessionsProvider.notifier)
                        .selectSession(session.id);
                    if (isDrawer) {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.25)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                          color: isSelected
                              ? accentColor
                              : (isDark
                                    ? Colors.white54
                                    : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            session.title,
                            style: GoogleFonts.outfit(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                              color: isSelected
                                  ? (isDark
                                        ? Colors.white
                                        : AppColors.oceanNavy)
                                  : (isDark
                                        ? Colors.white70
                                        : AppColors.lightTextPrimary),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Action menu for editing/renaming/deleting the thread
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 16,
                            color: isDark
                                ? Colors.white30
                                : AppColors.lightTextTertiary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    renameTitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    deleteLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (action) {
                            if (action == 'rename') {
                              final textController = TextEditingController(
                                text: session.title,
                              );
                              showDialog(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E1C24)
                                      : Colors.white,
                                  title: Text(
                                    renameTitle,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: TextField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx),
                                      child: Text(cancelLabel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref
                                            .read(chatSessionsProvider.notifier)
                                            .renameSession(
                                              session.id,
                                              textController.text.trim(),
                                            );
                                        Navigator.pop(dialogCtx);
                                      },
                                      child: Text(saveLabel),
                                    ),
                                  ],
                                ),
                              );
                            } else if (action == 'delete') {
                              showDialog(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E1C24)
                                      : Colors.white,
                                  title: Text(
                                    deleteConfirmTitle,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    deleteConfirmDesc,
                                    style: GoogleFonts.quicksand(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx),
                                      child: Text(cancelLabel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref
                                            .read(chatSessionsProvider.notifier)
                                            .deleteSession(session.id);
                                        Navigator.pop(dialogCtx);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      child: Text(
                                        deleteLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
