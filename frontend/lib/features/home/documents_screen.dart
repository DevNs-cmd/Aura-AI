import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:mime/mime.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/localization/generated/app_localizations.dart';
import 'file_provider.dart';
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
  // Holds the last-picked file so the upload callback can send bytes to backend.
  PlatformFile? _pickedFile;

  // Track selection state
  final Set<String> _selectedFileNames = {};

  // Search query state
  String _searchQuery = "";
  bool _isSearching = false;

  // Upload state
  String? _uploadingFileName;
  String _uploadingFileSize = '1.5 MB';
  String _uploadingFileType = 'PDF';

  // The actual upload future, passed to UploadProgressCard so it can wait.
  Future<void>? _uploadFuture;


  void _showUploadSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UploadSourceSheet(
          onSourceSelected: (source) {
            Navigator.pop(context);
            _pickDocument(source);
          },
        );
      },
    );
  }

  Future<void> _pickDocument(String source) async {
    if (source == 'File') {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
          withData: kIsWeb, // on web, load bytes eagerly (path is unavailable)
        );
        if (!mounted) return;
        if (result != null && result.files.single.name.isNotEmpty) {
          final file = result.files.single;
          String sizeStr = '1.0 MB';
          if (file.size > 0) {
            final kb = file.size / 1024;
            if (kb > 1024) {
              sizeStr = '${(kb / 1024).toStringAsFixed(1)} MB';
            } else {
              sizeStr = '${kb.toStringAsFixed(0)} KB';
            }
          }
          setState(() {
            _pickedFile = file;
            _uploadingFileName = file.name;
            _uploadingFileSize = sizeStr;
            _uploadingFileType = file.extension?.toUpperCase() ?? 'FILE';
            // Start upload immediately and hand the future to the progress card.
            _uploadFuture = _runUpload(file);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    } else if (source == 'Camera') {
      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Camera Unavailable'),
            content: const Text('Camera scan is not supported on web browsers in this environment. Please upload a photo from your gallery instead.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      try {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.camera);
        if (!mounted) return;
        if (picked != null) {
          setState(() {
            _uploadingFileName = 'Camera Scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
            _uploadingFileSize = '850 KB';
            _uploadingFileType = 'JPG';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing scan: $e')),
        );
      }
    } else if (source == 'Drive') {
      // Simulate Drive import
      setState(() {
        _uploadingFileName = 'Imported Project Docs.pdf';
        _uploadingFileSize = '4.1 MB';
        _uploadingFileType = 'PDF';
      });
    }
  }

  /// Performs the actual file upload + indexing. Called right when the file
  /// is picked. The returned Future is passed to [UploadProgressCard] so the
  /// card can wait for it before dismissing.
  Future<void> _runUpload(PlatformFile file) async {
    final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';
    try {
      if (kIsWeb) {
        // On web, dart:io File and .path are unavailable — use bytes directly.
        final bytes = file.bytes;
        if (bytes == null) throw Exception('Could not read file bytes');
        await ref.read(fileProvider.notifier).uploadFileFromBytes(
              bytes: bytes,
              fileName: file.name,
              contentType: mimeType,
            );
      } else {
        if (file.path == null) throw Exception('File path unavailable');
        await ref.read(fileProvider.notifier).uploadFile(
              file: File(file.path!),
              fileName: file.name,
              contentType: mimeType,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      rethrow;
    }
  }

  /// Called by [UploadProgressCard] once the animation + upload are both done.
  Future<void> _onUploadComplete() async {
    if (!mounted) return;
    setState(() {
      _uploadingFileName = null;
      _pickedFile = null;
      _uploadFuture = null;
    });
  }



  void _deleteDocument(String name) {
    try {
      final fileState = ref.read(fileProvider);
      final file = fileState.files.firstWhere((f) => f.name == name);
      ref.read(fileProvider.notifier).removeFile(file.id);
      setState(() {
        _selectedFileNames.remove(name);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed "$name" from workspace.')),
      );
    } catch (_) {}
  }

  /// Send a question to the RAG backend and show the answer in a sheet.
  Future<void> _askAura(String question) async {
    if (question.trim().isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnswerSheet(
        question: question,
        ragStream: ref.read(ragQueryProvider.notifier).ask(question),
        ragStateReader: () => ref.read(ragQueryProvider),
      ),
    );
  }

  void _deleteSelectedDocuments() {
    final fileState = ref.read(fileProvider);
    final idsToDelete = fileState.files
        .where((f) => _selectedFileNames.contains(f.name))
        .map((f) => f.id)
        .toList();
    ref.read(fileProvider.notifier).removeMultipleFiles(idsToDelete);
    final count = _selectedFileNames.length;
    setState(() {
      _selectedFileNames.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed $count document(s) from workspace.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileState = ref.watch(fileProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accentColor;

    // Filter documents based on query
    final filteredDocs = fileState.files.where((doc) {
      final name = doc.name.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141318)
          : (themeState.hasMoodSelected ? themeState.moodTheme.background : AppColors.lightBackground),
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
                    color: isDark ? Colors.white30 : AppColors.lightTextTertiary,
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
                    fileState.files.map((d) => d.name),
                  );
                });
              }
              // sort / storage are UI-only for now
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
            fileState.files.isEmpty && _uploadingFileName == null
                ? DocumentEmptyState(onAddFilesPressed: _showUploadSourceSheet)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        KnowledgeOrb(
                          documentCount: fileState.files.length,
                          selectedCount: _selectedFileNames.length,
                          isAnalyzing: _uploadingFileName != null,
                        ),
                        const SizedBox(height: 24),
                        if (_uploadingFileName != null) ...[
                          UploadProgressCard(
                            fileName: _uploadingFileName!,
                            uploadFuture: _uploadFuture,
                            onComplete: _onUploadComplete,
                          ),
                          const SizedBox(height: 24),
                        ],
                        AskFilesBar(
                          selectedCount: _selectedFileNames.length,
                          hasDocuments: fileState.files.isNotEmpty,
                          onUploadPressed: _showUploadSourceSheet,
                          onSubmit: _askAura,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.documentsTryAsking,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
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
                                label: AppLocalizations.of(context)!.documentsSuggestionSummarize,
                                icon: Icons.notes_rounded,
                                onTap: () => _askAura(
                                  AppLocalizations.of(context)!.documentsSuggestionSummarize,
                                ),
                              ),
                              const SizedBox(width: 12),
                              QuickQuestionCard(
                                label: AppLocalizations.of(context)!.documentsSuggestionDeadlines,
                                icon: Icons.access_time_rounded,
                                onTap: () => _askAura(
                                  AppLocalizations.of(context)!.documentsSuggestionDeadlines,
                                ),
                              ),
                              const SizedBox(width: 12),
                              QuickQuestionCard(
                                label: AppLocalizations.of(context)!.documentsSuggestionMainIdeas,
                                icon: Icons.lightbulb_outline_rounded,
                                onTap: () => _askAura(
                                  AppLocalizations.of(context)!.documentsSuggestionMainIdeas,
                                ),
                              ),
                              const SizedBox(width: 12),
                              QuickQuestionCard(
                                label: AppLocalizations.of(context)!.documentsSuggestionActionItems,
                                icon: Icons.track_changes_rounded,
                                onTap: () => _askAura(
                                  AppLocalizations.of(context)!.documentsSuggestionActionItems,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (fileState.files.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.documentsYourKnowledge,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
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
                            final docName = doc.name;
                            final isSelected = _selectedFileNames.contains(docName);
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
                                  size: doc.size,
                                  type: doc.type,
                                  isSelected: isSelected,
                                  onTap: () {
                                    context.push(
                                      '/document-detail',
                                      extra: {
                                        'name': docName,
                                        'size': doc.size,
                                        'type': doc.type,
                                      },
                                    );
                                  },
                                  onDelete: () => _deleteDocument(docName),
                                  onAskAura: () => _askAura(
                                    'Tell me about "${docName}"',
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
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
      floatingActionButton: fileState.files.isEmpty || _selectedFileNames.isNotEmpty
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

// ---------------------------------------------------------------------------
// Self-contained answer sheet — owns its own loading/result state via
// FutureBuilder so it never needs to pop itself or touch the router.
// ---------------------------------------------------------------------------
class _AnswerSheet extends StatefulWidget {
  final String question;
  final Future<void> ragStream;
  final RagQueryState Function() ragStateReader;

  const _AnswerSheet({
    required this.question,
    required this.ragStream,
    required this.ragStateReader,
  });

  @override
  State<_AnswerSheet> createState() => _AnswerSheetState();
}

class _AnswerSheetState extends State<_AnswerSheet> {
  String? _answer;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.ragStream.then((_) {
      if (!mounted) return;
      final s = widget.ragStateReader();
      setState(() {
        _loading = false;
        _answer = s.answer;
        _error = s.error;
      });
    }).catchError((Object _) {
      if (!mounted) return;
      final s = widget.ragStateReader();
      setState(() {
        _loading = false;
        _error = s.error ?? 'Something went wrong. Please try again.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C24) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _loading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 32),
                            CircularProgressIndicator(color: accentColor),
                            const SizedBox(height: 16),
                            Text(
                              'Aura is reading your documents...',
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.redAccent, size: 28),
                              const SizedBox(height: 12),
                              Text(
                                'Something went wrong. Please try again.',
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _answer ?? '',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
