/// YAML-driven PM3 command catalog for terminal quick input/suggestions.
library;

import 'package:flutter/services.dart';

class Pm3CommandEntry {
  final String className;
  final String name;
  final String command;
  final String description;
  final List<String> params;

  const Pm3CommandEntry({
    required this.className,
    required this.name,
    required this.command,
    required this.description,
    this.params = const [],
  });

  String get label => '$command  (${className.replaceAll('Cmd', '')}.$name)';

  bool matches(String query) {
    if (query.trim().isEmpty) return false;
    final q = query.toLowerCase();
    return command.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q) ||
        className.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        params.any((p) => p.toLowerCase().contains(q));
  }

  bool commandPrefixMatches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    return command.toLowerCase().startsWith(q);
  }

  bool appliesToInput(String input) {
    final v = input.trim().toLowerCase();
    final cmd = command.toLowerCase();
    return v == cmd || v.startsWith('$cmd ');
  }
}

class Pm3CommandCatalog {
  static const _zhAsset = 'docs/pm3_commands_help.zh.yaml';
  static const _enAsset = 'docs/pm3_commands_help.yaml';

  static Future<List<Pm3CommandEntry>> load({bool preferZh = true}) async {
    final text = await _loadYamlText(preferZh: preferZh);
    return _parseEntries(text);
  }

  static Future<String> _loadYamlText({required bool preferZh}) async {
    try {
      return await rootBundle.loadString(preferZh ? _zhAsset : _enAsset);
    } catch (_) {
      return rootBundle.loadString(preferZh ? _enAsset : _zhAsset);
    }
  }

  /// Lightweight line parser for our generated YAML structure.
  static List<Pm3CommandEntry> _parseEntries(String yamlText) {
    final entries = <Pm3CommandEntry>[];

    String currentClass = '';
    String currentName = '';
    String currentCommand = '';
    String currentDescription = '';
    List<String> currentParams = [];
    bool inParams = false;

    void flushCurrent() {
      if (currentCommand.isEmpty) return;
      entries.add(Pm3CommandEntry(
        className: currentClass,
        name: currentName,
        command: currentCommand,
        description: currentDescription,
        params: List.unmodifiable(currentParams),
      ));
      currentName = '';
      currentCommand = '';
      currentDescription = '';
      currentParams = [];
      inParams = false;
    }

    String? extractQuotedValue(String line, String key) {
      final marker = '$key: "';
      final idx = line.indexOf(marker);
      if (idx < 0) return null;
      final start = idx + marker.length;
      final end = line.indexOf('"', start);
      if (end < 0) return null;
      return line.substring(start, end);
    }

    for (final rawLine in yamlText.split('\n')) {
      final line = rawLine.trimRight();

      if (line.trimLeft().startsWith('- class:')) {
        flushCurrent();
        currentClass = extractQuotedValue(line, 'class') ?? '';
        inParams = false;
        continue;
      }

      if (line.trimLeft().startsWith('- name:')) {
        flushCurrent();
        currentName = extractQuotedValue(line, 'name') ?? '';
        inParams = false;
        continue;
      }

      if (line.trimLeft().startsWith('command:')) {
        currentCommand = extractQuotedValue(line, 'command') ?? '';
        inParams = false;
        continue;
      }

      if (line.trimLeft().startsWith('description:')) {
        currentDescription = extractQuotedValue(line, 'description') ?? '';
        inParams = false;
        continue;
      }

      if (line.trimLeft().startsWith('params:')) {
        inParams = true;
        continue;
      }

      if (line.trimLeft().startsWith('help_source:')) {
        inParams = false;
        continue;
      }

      if (inParams) {
        final param = _extractParamLine(line);
        if (param != null && param.isNotEmpty) {
          currentParams.add(param);
        }
        continue;
      }
    }

    flushCurrent();

    // De-duplicate by command text while keeping first occurrence.
    final seen = <String>{};
    final deduped = <Pm3CommandEntry>[];
    for (final entry in entries) {
      if (entry.command.isEmpty) continue;
      if (seen.add(entry.command)) deduped.add(entry);
    }

    deduped.sort((a, b) => a.command.compareTo(b.command));
    return deduped;
  }

  static String? _extractParamLine(String line) {
    final trimmed = line.trimLeft();
    if (!trimmed.startsWith('- "')) return null;
    const prefix = '- "';
    final start = trimmed.indexOf(prefix);
    if (start < 0) return null;
    final contentStart = start + prefix.length;
    final contentEnd = trimmed.lastIndexOf('"');
    if (contentEnd <= contentStart) return null;
    return trimmed.substring(contentStart, contentEnd).trim();
  }
}
