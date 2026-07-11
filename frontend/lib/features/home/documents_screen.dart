import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/localization/generated/app_localizations.dart';
import 'widgets/ask_your_files/knowledge_orb.dart';
import 'widgets/ask_your_files/ask_files_bar.dart';
import 'widgets/ask_your_files/quick_question_card.dart';
import 'widgets/ask_your_files/aura_document_card.dart';
import 'widgets/ask_your_files/document_empty_state.dart';
import 'widgets/ask_your_files/document_selection_bar.dart';
import 'widgets/ask_your_files/upload_source_sheet.dart';
import 'widgets/ask_your_files/upload_progress_card.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  // Local list state for files so user can interactively delete or add new mock files!
  final List<Map<String, dynamic>> _documents = [
    {'name': 'Project Roadmap.pdf', 'size': '2.4 MB', 'type': 'PDF'},
    {'name': 'Flutter Guide.docx', 'size': '1.1 MB', 'type': 'DOCX'},
    {'name': 'Notes.txt', 'size': '320 KB', 'type': 'TXT'},
    {'name': 'Design Ideas.pdf', 'size': '1.8 MB', 'type': 'PDF'},
  ];

  // Track selection state
  final Set<String> _selectedFileNames = {};

  // Search query state
  String _searchQuery = "";
  bool _isSearching = false;

  // Upload simulation state
  String? _uploadingFileName;

  void _showUploadSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UploadSourceSheet(
          onSourceSelected: (source) {
            Navigator.pop(context);
            setState(() {
              _uploadingFileName = 'Uploaded Doc_${_documents.length + 1}.pdf';
            });
          },
        );
      },
    );
  }

  void _onUploadComplete() {
    if (_uploadingFileName != null) {
      setState(() {
        _documents.add({
          'name': _uploadingFileName!,
          'size': '1.5 MB',
          'type': 'PDF',
        });
        _uploadingFileName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document successfully parsed and indexed!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _deleteDocument(String name) {
    setState(() {
      _documents.removeWhere((doc) => doc['name'] == name);
      _selectedFileNames.remove(name);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "$name" from workspace.')));
  }

  void _deleteSelectedDocuments() {
    final count = _selectedFileNames.length;
    setState(() {
      _documents.removeWhere((doc) => _selectedFileNames.contains(doc['name']));
      _selectedFileNames.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed $count document(s) from workspace.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Filter documents based on query
    final filteredDocs = _documents.where((doc) {
      final name = (doc['name'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

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
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Search files...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white30
                        : AppColors.lightTextTertiary,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : Text(
                'Ask Your Files',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
        centerTitle: true,
        actions: [
          // Search toggle icon
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = "";
                }
                _isSearching = !_isSearching;
              });
            },
          ),

          // Contextual More Menu Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
            onSelected: (val) {
              if (val == 'select') {
                setState(() {
                  _selectedFileNames.addAll(
                    _documents.map((d) => d['name'] as String),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action "$val" selected (Mock).')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'select', child: Text('Select All')),
              PopupMenuItem(value: 'sort', child: Text('Sort Files')),
              PopupMenuItem(value: 'storage', child: Text('Storage Info')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _documents.isEmpty && _uploadingFileName == null
                ? DocumentEmptyState(onAddFilesPressed: _showUploadSourceSheet)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Knowledge Orb Hero
                        KnowledgeOrb(
                          documentCount: _documents.length,
                          selectedCount: _selectedFileNames.length,
                          isAnalyzing: _uploadingFileName != null,
                        ),
                        const SizedBox(height: 24),

                        // 2. Upload Progress Card (Simulated Phase Loader)
                        if (_uploadingFileName != null) ...[
                          UploadProgressCard(
                            fileName: _uploadingFileName!,
                            onComplete: _onUploadComplete,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 3. Primary Ask Bar
                        AskFilesBar(
                          selectedCount: _selectedFileNames.length,
                          hasDocuments: _documents.isNotEmpty,
                          onUploadPressed: _showUploadSourceSheet,
                          onSubmit: (text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.documentsMockAskedSnackbar(text),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // 4. Quick Suggestions Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.documentsTryAsking,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 115,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              QuickQuestionCard(
                                label: AppLocalizations.of(
                                  context,
                                )!.documentsSuggestionSummarize,
                                icon: Icons.notes_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.documentsMockAskedSnackbar(
                                          AppLocalizations.of(
                                            context,
                                          )!.documentsSuggestionSummarize,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              QuickQuestionCard(
                                label: AppLocalizations.of(
                                  context,
                                )!.documentsSuggestionDeadlines,
                                icon: Icons.access_time_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.documentsMockAskedSnackbar(
                                          AppLocalizations.of(
                                            context,
                                          )!.documentsSuggestionDeadlines,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              QuickQuestionCard(
                                label: AppLocalizations.of(
                                  context,
                                )!.documentsSuggestionMainIdeas,
                                icon: Icons.lightbulb_outline_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.documentsMockAskedSnackbar(
                                          AppLocalizations.of(
                                            context,
                                          )!.documentsSuggestionMainIdeas,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              QuickQuestionCard(
                                label: AppLocalizations.of(
                                  context,
                                )!.documentsSuggestionActionItems,
                                icon: Icons.track_changes_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.documentsMockAskedSnackbar(
                                          AppLocalizations.of(
                                            context,
                                          )!.documentsSuggestionActionItems,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 5. Document Library Cards List
                        if (_documents.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.documentsYourKnowledge,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  AppLocalizations.of(context)!.documentsSeeAll,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...filteredDocs.map((doc) {
                            final docName = doc['name'] as String;
                            final isSelected = _selectedFileNames.contains(
                              docName,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedFileNames.remove(docName);
                                    } else {
                                      _selectedFileNames.add(docName);
                                    }
                                  });
                                },
                                child: AuraDocumentCard(
                                  name: docName,
                                  size: doc['size'] as String,
                                  type: doc['type'] as String,
                                  isSelected: isSelected,
                                  onTap: () {
                                    context.push(
                                      '/document-detail',
                                      extra: {
                                        'name': docName,
                                        'size': doc['size'] as String,
                                        'type': doc['type'] as String,
                                      },
                                    );
                                  },
                                  onDelete: () => _deleteDocument(docName),
                                  onAskAura: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.documentsMockAskingSnackbar(
                                            docName,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),

            // 6. Document Selection Action Bar (Displays floating at bottom overlay)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: DocumentSelectionBar(
                selectedCount: _selectedFileNames.length,
                onClearAll: () {
                  setState(() {
                    _selectedFileNames.clear();
                  });
                },
                onDeleteAll: _deleteSelectedDocuments,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _documents.isEmpty || _selectedFileNames.isNotEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                text: AppLocalizations.of(context)!.documentsAddFiles,
                backgroundColor: accentColor,
                onPressed: _showUploadSourceSheet,
              ),
            ),
    );
  }
}
