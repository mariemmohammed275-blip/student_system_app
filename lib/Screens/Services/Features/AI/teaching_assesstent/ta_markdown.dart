import 'package:flutter/material.dart';
import 'ta_theme.dart';

// ─── Markdown Text Renderer ───────────────────────────────────────────────────
// Lightweight markdown parser — no external package needed.
// Handles: ## headings, **bold**, `code`, ```code blocks```, - bullets, blank lines.

class TaMarkdownText extends StatelessWidget {
  const TaMarkdownText({super.key, required this.text, required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    bool inCodeBlock = false;
    final codeLines = <String>[];

    void flushCodeBlock() {
      if (codeLines.isEmpty) return;
      widgets.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[900]
                : taNeutralDark.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: taBorder),
          ),
          child: SelectableText(
            codeLines.join('\n'),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.55,
              color: isDark ? Colors.greenAccent[200] : taPrimary,
            ),
          ),
        ),
      );
      codeLines.clear();
    }

    for (final line in lines) {
      // Code block toggle
      if (line.trimLeft().startsWith('```')) {
        if (inCodeBlock) {
          inCodeBlock = false;
          flushCodeBlock();
        } else {
          inCodeBlock = true;
        }
        continue;
      }

      if (inCodeBlock) {
        codeLines.add(line);
        continue;
      }

      // H2  ## ...
      if (line.startsWith('## ')) {
        widgets.add(const SizedBox(height: 10));
        widgets.add(
          Text(
            line.substring(3).trim(),
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: taPrimary,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // H3  ### ...
      if (line.startsWith('### ')) {
        widgets.add(
          Text(
            line.substring(4).trim(),
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : taNeutralDark,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 2));
        continue;
      }

      // Bullet  - ... (with optional indent)
      final bulletMatch = RegExp(r'^(\s*)- (.+)').firstMatch(line);
      if (bulletMatch != null) {
        final indent = bulletMatch.group(1)!.length;
        final content = bulletMatch.group(2)!;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: indent * 6.0, top: 3, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 8),
                  child: Container(
                    width: indent == 0 ? 6 : 4,
                    height: indent == 0 ? 6 : 4,
                    decoration: BoxDecoration(
                      color: indent == 0 ? taPrimary : taSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: TaInlineText(text: content, isDark: isDark),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Blank line
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Normal paragraph line
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: TaInlineText(text: line, isDark: isDark),
        ),
      );
    }

    if (inCodeBlock) flushCodeBlock();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

// ─── Inline Text (bold + code) ────────────────────────────────────────────────

class TaInlineText extends StatelessWidget {
  const TaInlineText({super.key, required this.text, required this.isDark});
  final String text;
  final bool isDark;

  List<InlineSpan> _parse(String raw) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
    int cursor = 0;

    for (final match in pattern.allMatches(raw)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: raw.substring(cursor, match.start)));
      }
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: taPrimary,
              backgroundColor: taPrimary.withValues(alpha: 0.08),
            ),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < raw.length) spans.add(TextSpan(text: raw.substring(cursor)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14.5,
          height: 1.65,
          color: isDark ? Colors.white : Colors.black87,
        ),
        children: _parse(text),
      ),
    );
  }
}
