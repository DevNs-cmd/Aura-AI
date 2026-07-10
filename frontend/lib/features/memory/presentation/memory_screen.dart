import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../models/memory.dart';
import '../memory_provider.dart';
import 'create_memory_screen.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Personal', 'Work'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMemoryDetails(
    BuildContext context,
    Memory memory,
    Color accentColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
        title: Text(
          memory.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                memory.category.name.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              memory.description,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Created: ${DateFormat('yyyy-MM-dd hh:mm a').format(memory.storedAt)}',
                  style: GoogleFonts.quicksand(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              memory.isPinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              color: memory.isPinned ? accentColor : Colors.grey,
            ),
            onPressed: () {
              ref.read(memoryProvider.notifier).togglePinState(memory.id);
              Navigator.pop(dialogContext);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
            onPressed: () {
              ref.read(memoryProvider.notifier).removeMemory(memory.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Memory deleted')));
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeState themeState, {
    required String label,
    required bool isDark,
    required Color accentColor,
  }) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor
                : (isDark
                      ? const Color(0xFF1E1C24)
                      : (themeState.hasMoodSelected
                            ? themeState.moodTheme.cardColor
                            : Colors.white)),
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? const Color(0xFF2C2834)
                        : (themeState.hasMoodSelected
                              ? themeState.moodTheme.cardBorder
                              : AppColors.lightCardBorder),
                    width: 1.5,
                  ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(MemoryCategory cat) {
    switch (cat) {
      case MemoryCategory.personal:
        return Icons.person_outline_rounded;
      case MemoryCategory.work:
        return Icons.work_outline_rounded;
      case MemoryCategory.insight:
        return Icons.auto_awesome_rounded;
      case MemoryCategory.fact:
        return Icons.notes_rounded;
    }
  }

  Color _getCategoryColor(MemoryCategory cat, Color accentColor) {
    switch (cat) {
      case MemoryCategory.personal:
        return accentColor;
      case MemoryCategory.work:
        return const Color(0xFF7C8CFF);
      case MemoryCategory.insight:
        return const Color(0xFF57C7D4);
      default:
        return const Color(0xFFA58BFF);
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoryState = ref.watch(memoryProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Apply Filter & Search keyword logic
    final List<Memory> filteredMemories = memoryState.memories.where((m) {
      if (_selectedFilter == 'Personal' &&
          m.category != MemoryCategory.personal) {
        return false;
      }
      if (_selectedFilter == 'Work' && m.category != MemoryCategory.work) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = m.title.toLowerCase().contains(query);
        final matchDesc = m.description.toLowerCase().contains(query);
        return matchTitle || matchDesc;
      }
      return true;
    }).toList();

    // Sort Newest first
    filteredMemories.sort((a, b) => b.storedAt.compareTo(a.storedAt));

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected
                ? themeState.moodTheme.background
                : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Memory',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle ledger text
              Center(
                child: Text(
                  'Things I remember about you',
                  style: GoogleFonts.quicksand(
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Search Bar input
              Container(
                width: double.infinity,
                height: 48,
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
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? Colors.white38
                          : AppColors.lightTextTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search facts and insights...',
                          hintStyle: GoogleFonts.quicksand(
                            color: isDark
                                ? Colors.white30
                                : AppColors.lightTextTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          filled: false,
                        ),
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab filters row (All, Personal, Work) stretching horizontally
              Row(
                children: [
                  _buildFilterChip(
                    context,
                    themeState,
                    label: 'All',
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    context,
                    themeState,
                    label: 'Personal',
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    context,
                    themeState,
                    label: 'Work',
                    isDark: isDark,
                    accentColor: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Reconstructed Timeline Section matching the reference design
              if (filteredMemories.isEmpty)
                _buildEmptyState(isDark)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMemories.length,
                  itemBuilder: (context, index) {
                    final memory = filteredMemories[index];
                    final catColor = _getCategoryColor(
                      memory.category,
                      accentColor,
                    );
                    final catIcon = _getCategoryIcon(memory.category);
                    final isLast = index == filteredMemories.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Timeline indicator left column
                          Column(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(catIcon, color: catColor, size: 18),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: isDark
                                        ? const Color(0xFF2C2834)
                                        : (themeState.hasMoodSelected
                                              ? themeState.moodTheme.cardBorder
                                              : AppColors.lightCardBorder),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Text Info and Chevron
                          Expanded(
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    bottom: 24,
                                  ),
                                  title: Text(
                                    memory.title,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.text,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _getTimeAgo(memory.storedAt),
                                      style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white60
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: isDark
                                        ? Colors.white30
                                        : AppColors.textTertiary,
                                  ),
                                  onTap: () => _showMemoryDetails(
                                    context,
                                    memory,
                                    accentColor,
                                    isDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 80), // offset for bottom action button
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: PrimaryButton(
          text: '+ Add Memory',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateMemoryScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 48,
            color: isDark ? Colors.white24 : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No memories found.',
            style: GoogleFonts.quicksand(
              color: isDark ? Colors.white54 : AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
