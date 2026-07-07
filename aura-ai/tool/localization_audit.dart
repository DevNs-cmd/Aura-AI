import 'dart:io';
import 'dart:convert';

void main() async {
  print("Starting localization audit...");

  final allowlistFile = File('tool/localization_allowlist.yaml');
  if (!allowlistFile.existsSync()) {
    print("Error: localization_allowlist.yaml not found.");
    exit(1);
  }

  // Simple manual YAML parser for the allowlist
  final exactStrings = <String>{};
  final regexPatterns = <RegExp>[];
  final ignoredFiles = <RegExp>[];

  String currentSection = '';
  for (var line in allowlistFile.readAsLinesSync()) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    if (line.endsWith(':')) {
      currentSection = line.substring(0, line.length - 1).trim();
      continue;
    }

    if (line.startsWith('-')) {
      var value = line.substring(1).trim();
      // Remove surrounding quotes if present
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }

      // Unescape some basic things
      value = value
          .replaceAll(r'\"', '"')
          .replaceAll(r"\'", "'")
          .replaceAll(r'\\', '\\');

      if (currentSection == 'exact_strings') {
        exactStrings.add(value);
      } else if (currentSection == 'regex_patterns') {
        regexPatterns.add(RegExp(value));
      } else if (currentSection == 'ignored_files') {
        ignoredFiles.add(RegExp(value));
      }
    }
  }

  print(
    "Loaded allowlist: ${exactStrings.length} exact strings, ${regexPatterns.length} regex patterns, ${ignoredFiles.length} ignored file patterns.",
  );

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print("Error: lib/ directory not found.");
    exit(1);
  }

  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  int totalFilesScanned = 0;
  int filesWithUserFacingStrings = 0;
  int completeFiles = 0;
  int partialFiles = 0;
  int notStartedFiles = 0;
  int totalCandidateStrings = 0;
  int totalLocalizedStringsCount = 0;
  int remainingHardcodedStrings = 0;

  final manifestFiles = <Map<String, dynamic>>[];
  final auditFindings = <Map<String, dynamic>>[];
  final inventoryItems = <Map<String, dynamic>>[];

  // Regular expression to match string literals (single/double quotes, and triple quotes)
  // Let's use a simpler state-based or regex approach for string literal extraction
  final stringRegex = RegExp(
    r'"""([\s\S]*?)"""|'
    r"'''([\s\S]*?)'''|"
    r'"((?:[^"\\]|\\.)*)"|'
    r"'((?:[^'\\]|\\.)*)'",
  );

  // Localization usage pattern
  final localizationRegex = RegExp(
    r'AppLocalizations\.of\(context\)(?:\!\s*)?\.([a-zA-Z0-9_]+)|'
    r'localizations\.([a-zA-Z0-9_]+)',
  );

  for (final file in dartFiles) {
    final relativePath = file.path.replaceAll('\\', '/');

    // Check if the file is ignored
    bool isIgnored = false;
    for (final pattern in ignoredFiles) {
      if (pattern.hasMatch(relativePath)) {
        isIgnored = true;
        break;
      }
    }
    if (relativePath.contains('/generated/')) {
      isIgnored = true;
    }
    if (isIgnored) {
      continue;
    }

    totalFilesScanned++;
    final content = file.readAsStringSync();
    final lines = content.split('\n');

    // Find all localized keys in this file
    final localizedKeys = <String>{};
    for (final match in localizationRegex.allMatches(content)) {
      final key = match.group(1) ?? match.group(2);
      if (key != null) {
        localizedKeys.add(key);
      }
    }

    int fileHardcodedCount = 0;
    int fileLocalizedCount = localizedKeys.length;
    final fileHardcodedFindings = <Map<String, dynamic>>[];

    // Scan line by line to keep track of line numbers
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;

      // Check if line contains a comment, skip scanning the comment part
      var codePart = line;
      final commentIdx = line.indexOf('//');
      if (commentIdx != -1) {
        codePart = line.substring(0, commentIdx);
      }
      if (codePart.trim().startsWith('import') ||
          codePart.trim().startsWith('export')) {
        continue; // skip imports
      }

      for (final match in stringRegex.allMatches(codePart)) {
        // Extract raw string value
        String? val =
            match.group(1) ??
            match.group(2) ??
            match.group(3) ??
            match.group(4);
        if (val == null) continue;

        // Skip string interpolation variables and placeholders inside string if they are just that
        // Clean value of any escape characters
        final cleanVal = val
            .replaceAll(r'\"', '"')
            .replaceAll(r"\'", "'")
            .replaceAll(r'\\', '\\');

        // Rules to check if it's a valid candidate user-facing string:
        // 1. Must contain at least one letter
        if (!RegExp(r'[a-zA-Z]').hasMatch(cleanVal)) {
          continue;
        }

        // 2. Must not be in the exact match allowlist
        if (exactStrings.contains(cleanVal) ||
            exactStrings.contains(cleanVal.trim())) {
          continue;
        }

        // 3. Must not match any of the regex allowlist patterns
        bool isAllowed = false;
        for (final regex in regexPatterns) {
          if (regex.hasMatch(cleanVal)) {
            isAllowed = true;
            break;
          }
        }
        if (isAllowed) {
          continue;
        }

        // Let's do some context-based check. For example, if it's a log, router path, asset, exception, key, debug, etc., exclude it automatically.
        // We'll also guess if it's UI.
        String context = "Unknown";
        if (line.contains('Text(') ||
            line.contains('TextSpan(') ||
            line.contains('tooltip:') ||
            line.contains('semanticLabel:')) {
          context = "Text Widget / Tooltip";
        } else if (line.contains('labelText:') ||
            line.contains('hintText:') ||
            line.contains('helperText:') ||
            line.contains('errorText:')) {
          context = "Input Decoration";
        } else if (line.contains('title:') || line.contains('subtitle:')) {
          context = "Title/Subtitle";
        } else if (line.contains('label:') ||
            line.contains('message:') ||
            line.contains('content:')) {
          context = "Label/Content";
        } else if (line.contains('SnackBar') ||
            line.contains('AlertDialog') ||
            line.contains('Dialog')) {
          context = "Popup / Alert";
        } else if (line.contains('Button') ||
            line.contains('Chip') ||
            line.contains('Tab(')) {
          context = "Interactive Control";
        }

        fileHardcodedCount++;
        fileHardcodedFindings.add({
          "line": lineNum,
          "string": cleanVal,
          "context": context,
          "lineContent": line.trim(),
        });

        auditFindings.add({
          "filePath": relativePath,
          "line": lineNum,
          "string": cleanVal,
          "context": context,
          "lineContent": line.trim(),
        });
      }
    }

    final totalCandidates = fileHardcodedCount + fileLocalizedCount;
    String status = "NOT_STARTED";
    if (totalCandidates == 0) {
      status = "EXCLUDED";
    } else if (fileHardcodedCount == 0 && fileLocalizedCount > 0) {
      status = "COMPLETE";
    } else if (fileLocalizedCount > 0 && fileHardcodedCount > 0) {
      status = "PARTIAL";
    }

    if (status == "COMPLETE") {
      completeFiles++;
    } else if (status == "PARTIAL") {
      partialFiles++;
      filesWithUserFacingStrings++;
    } else if (status == "NOT_STARTED") {
      notStartedFiles++;
      filesWithUserFacingStrings++;
    }

    totalCandidateStrings += totalCandidates;
    totalLocalizedStringsCount += fileLocalizedCount;
    remainingHardcodedStrings += fileHardcodedCount;

    manifestFiles.add({
      "path": relativePath,
      "feature": _determineFeature(relativePath),
      "candidateStringCount": totalCandidates,
      "localizedStringCount": fileLocalizedCount,
      "remainingHardcodedStringCount": fileHardcodedCount,
      "status": status,
      "excludedStrings": [],
      "arbKeys": localizedKeys.toList(),
    });

    if (totalCandidates > 0) {
      inventoryItems.add({
        "feature": _determineFeature(relativePath),
        "filePath": relativePath,
        "name": _determineClassName(relativePath, content),
        "userFacingStrings": totalCandidates > 0,
        "candidateCount": totalCandidates,
        "status": status,
        "arbKeys": localizedKeys.toList(),
        "notes": fileHardcodedCount > 0
            ? "Contains $fileHardcodedCount hardcoded strings"
            : "Fully localized with ${localizedKeys.length} keys",
      });
    }
  }

  // Create docs directory if not exists
  Directory('docs').createSync(recursive: true);

  // Write localization_manifest.json
  final manifest = {
    "files": manifestFiles,
    "summary": {
      "totalFilesScanned": totalFilesScanned,
      "filesWithUserFacingStrings": filesWithUserFacingStrings,
      "completeFiles": completeFiles,
      "partialFiles": partialFiles,
      "notStartedFiles": notStartedFiles,
      "totalCandidateStrings": totalCandidateStrings,
      "totalLocalizedStrings": totalLocalizedStringsCount,
      "remainingHardcodedStrings": remainingHardcodedStrings,
    },
  };
  File(
    'docs/localization_manifest.json',
  ).writeAsStringSync(JsonEncoder.withIndent('  ').convert(manifest));

  // Write LOCALIZATION_AUDIT_REPORT.md
  final auditReport = StringBuffer();
  auditReport.writeln("# Localization Audit Report");
  auditReport.writeln("\nGenerated on: ${DateTime.now().toIso8601String()}");
  auditReport.writeln("\n## Summary");
  auditReport.writeln("- **Total Files Scanned**: $totalFilesScanned");
  auditReport.writeln(
    "- **Remaining Hardcoded Strings**: $remainingHardcodedStrings",
  );
  auditReport.writeln(
    "- **Already Localized Strings**: $totalLocalizedStringsCount",
  );
  auditReport.writeln("- **Total Candidate Strings**: $totalCandidateStrings");
  auditReport.writeln("\n## Details by File");

  final filesWithHardcoded = <String, List<Map<String, dynamic>>>{};
  for (final finding in auditFindings) {
    final path = finding['filePath'] as String;
    filesWithHardcoded.putIfAbsent(path, () => []).add(finding);
  }

  if (filesWithHardcoded.isEmpty) {
    auditReport.writeln(
      "\n🎉 **All clear! No remaining hardcoded strings found.**",
    );
  } else {
    filesWithHardcoded.forEach((path, findings) {
      auditReport.writeln(
        "\n### [${path.split('/').last}](file:///${Directory.current.absolute.path.replaceAll('\\', '/')}/$path)",
      );
      auditReport.writeln(
        "Path: `$path` | Remaining hardcoded strings: **${findings.length}**",
      );
      auditReport.writeln(
        "\n| Line | Context | Hardcoded String | Line Content |",
      );
      auditReport.writeln(
        "|------|---------|------------------|--------------|",
      );
      for (final f in findings) {
        final escapedStr = (f['string'] as String)
            .replaceAll('|', '\\|')
            .replaceAll('\n', ' ');
        final escapedLine = (f['lineContent'] as String)
            .replaceAll('|', '\\|')
            .replaceAll('\n', ' ');
        auditReport.writeln(
          "| ${f['line']} | ${f['context']} | `$escapedStr` | `$escapedLine` |",
        );
      }
    });
  }

  File(
    'docs/LOCALIZATION_AUDIT_REPORT.md',
  ).writeAsStringSync(auditReport.toString());

  // Write LOCALIZATION_INVENTORY.md
  final inventoryReport = StringBuffer();
  inventoryReport.writeln("# Localization Inventory");
  inventoryReport.writeln(
    "\nThis file catalogs every UI surface in the Aura AI application, derived from code inspection.",
  );
  inventoryReport.writeln("\n## Category Summary");

  final categories = <String, List<Map<String, dynamic>>>{};
  for (final item in inventoryItems) {
    final feat = item['feature'] as String;
    categories.putIfAbsent(feat, () => []).add(item);
  }

  categories.forEach((feat, items) {
    int total = items.length;
    int complete = items.where((i) => i['status'] == 'COMPLETE').length;
    inventoryReport.writeln(
      "- **${feat.toUpperCase()}**: $complete/$total localized",
    );
  });

  inventoryReport.writeln("\n## Detailed Inventory");
  categories.forEach((feat, items) {
    inventoryReport.writeln("\n### ${feat.toUpperCase()}");
    inventoryReport.writeln(
      "\n| Component / Widget | File Path | Candidate Strings | Status | Notes |",
    );
    inventoryReport.writeln(
      "|--------------------|-----------|------------------|--------|-------|",
    );
    for (final item in items) {
      inventoryReport.writeln(
        "| **${item['name']}** | [${item['filePath'].split('/').last}](file:///${Directory.current.absolute.path.replaceAll('\\', '/')}/${item['filePath']}) | ${item['candidateCount']} | `${item['status']}` | ${item['notes']} |",
      );
    }
  });

  File(
    'docs/LOCALIZATION_INVENTORY.md',
  ).writeAsStringSync(inventoryReport.toString());

  print("\nAudit complete!");
  print("Total scanned: $totalFilesScanned files");
  print("Remaining hardcoded: $remainingHardcodedStrings strings");
  print("Saved manifest, audit report, and inventory.");
}

String _determineFeature(String path) {
  final parts = path.split('/');
  if (parts.length > 2 && parts[1] == 'features') {
    return parts[2];
  }
  if (parts.contains('routes') || parts.contains('navigation')) {
    return 'app shell';
  }
  return 'core';
}

String _determineClassName(String path, String content) {
  // Try to find the class name
  final classRegex = RegExp(r'class\s+([a-zA-Z0-9_]+)');
  final match = classRegex.firstMatch(content);
  if (match != null) {
    return match.group(1) ?? path.split('/').last;
  }
  return path.split('/').last;
}
