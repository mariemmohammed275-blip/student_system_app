import 'package:flutter/material.dart';
import 'ta_theme.dart';
import 'ta_markdown.dart';
import 'ta_shared_widgets.dart';

// ─── Exam Result Card ─────────────────────────────────────────────────────────

class TaExamResultCard extends StatelessWidget {
  const TaExamResultCard({super.key, required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = result.split('\n\n');
    final scoreLine = lines.isNotEmpty ? lines.first : '';
    final questionBlocks = lines.skip(1).toList();

    final scoreMatch = RegExp(r'(\d+)/(\d+)').firstMatch(scoreLine);
    final correct = int.tryParse(scoreMatch?.group(1) ?? '0') ?? 0;
    final total = int.tryParse(scoreMatch?.group(2) ?? '1') ?? 1;
    final percent = total > 0 ? (correct / total * 100).round() : 0;

    final scoreColor = percent >= 70
        ? taSecondary
        : percent >= 40
        ? taAccent
        : Colors.red;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : taSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: taBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: taPrimary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: scoreColor, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Exam Results',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scoreColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $correct / $total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scoreColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Question result blocks
                ...questionBlocks.map((block) {
                  final isCorrect = block.trimLeft().startsWith('Correct');
                  final blockColor = isCorrect ? taSecondary : Colors.red;

                  final blockLines = block.trim().split('\n');
                  final questionLine = blockLines.isNotEmpty
                      ? blockLines[0]
                      : '';
                  final yourAnswer = blockLines.firstWhere(
                    (l) => l.startsWith('Your answer:'),
                    orElse: () => '',
                  );
                  final correctAnswer = blockLines.firstWhere(
                    (l) => l.startsWith('Correct answer:'),
                    orElse: () => '',
                  );
                  final explanation = blockLines.firstWhere(
                    (l) => l.startsWith('Explanation:'),
                    orElse: () => '',
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[850]
                          : blockColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: blockColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: blockColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                questionLine.replaceFirst(
                                  RegExp(r'^(Correct|Wrong) - '),
                                  '',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (yourAnswer.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _ResultRow(
                            label: 'Your answer',
                            value: yourAnswer.replaceFirst('Your answer: ', ''),
                            color: isCorrect ? taSecondary : Colors.red,
                          ),
                        ],
                        if (correctAnswer.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _ResultRow(
                            label: 'Correct answer',
                            value: correctAnswer.replaceFirst(
                              'Correct answer: ',
                              '',
                            ),
                            color: taSecondary,
                          ),
                        ],
                        if (explanation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: taPrimary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: taPrimary,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    explanation.replaceFirst(
                                      'Explanation: ',
                                      '',
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.45,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 13, color: color)),
        ),
      ],
    );
  }
}

// ─── Key Terms Card ───────────────────────────────────────────────────────────

class TaKeyTermsCard extends StatelessWidget {
  const TaKeyTermsCard({super.key, required this.termsRaw});
  final String termsRaw;

  List<Map<String, String>> _parseTerms(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      final trimmed = raw.trim();
      final jsonStr = trimmed.startsWith('[') ? trimmed : '[$trimmed]';
      if (jsonStr.contains('"term"')) {
        final results = <Map<String, String>>[];
        final terms = RegExp(
          r'"term"\s*:\s*"([^"]+)"',
        ).allMatches(jsonStr).map((m) => m.group(1) ?? '').toList();
        final defs = RegExp(
          r'"definition"\s*:\s*"([^"]+)"',
        ).allMatches(jsonStr).map((m) => m.group(1) ?? '').toList();
        for (var i = 0; i < terms.length; i++) {
          results.add({
            'term': terms[i],
            'definition': i < defs.length ? defs[i] : '',
          });
        }
        if (results.isNotEmpty) return results;
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsed = _parseTerms(termsRaw);

    if (termsRaw.trim().isEmpty || parsed.isEmpty) {
      return TaSummaryOutputCard(
        title: 'Key Terms & Definitions',
        icon: Icons.menu_book_outlined,
        text: parsed.isEmpty ? termsRaw : '',
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : taSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: taBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: taPrimary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: taPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Key Terms & Definitions',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: taSecondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${parsed.length} terms',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: taSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: parsed.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    bottom: i < parsed.length - 1 ? 10 : 0,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: taBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: taAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: taAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['term'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((item['definition'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: taSoftBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['definition'] ?? '',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: isDark ? Colors.black : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Output Card ──────────────────────────────────────────────────────

class TaSummaryOutputCard extends StatelessWidget {
  const TaSummaryOutputCard({
    super.key,
    required this.title,
    required this.icon,
    required this.text,
  });
  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : taSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: taBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: taPrimary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: taPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: text.trim().isEmpty
                ? Text(
                    'Output will appear here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : TaMarkdownText(text: text.trim(), isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ─── Q&A Answer Card ──────────────────────────────────────────────────────────

class TaQaAnswerCard extends StatelessWidget {
  const TaQaAnswerCard({
    super.key,
    required this.title,
    required this.text,
    required this.loading,
  });
  final String title;
  final String text;
  final bool loading;

  static final _scorePrefix = RegExp(r'^\{"score"\s*:\s*"[^"]*"\}');

  String _clean(String raw) => raw.replaceFirst(_scorePrefix, '').trimLeft();

  bool? _scoreValue(String raw) {
    final m = RegExp(r'"score"\s*:\s*"([^"]+)"').firstMatch(raw);
    if (m == null) return null;
    return m.group(1)?.toLowerCase() == 'yes';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleaned = _clean(text);
    final isEmpty = cleaned.trim().isEmpty;
    final scoreOk = _scoreValue(text);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : taSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: taBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: taPrimary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: taPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: taPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: taPrimary,
                    ),
                  )
                else if (scoreOk != null)
                  _ScoreBadge(isOnTopic: scoreOk),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: isEmpty && !loading
                ? Text(
                    'Answer will appear here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : TaMarkdownText(text: cleaned, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.isOnTopic});
  final bool isOnTopic;

  @override
  Widget build(BuildContext context) {
    final color = isOnTopic ? taSecondary : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnTopic ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isOnTopic ? 'On-Topic' : 'Off-Topic',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generated Question Card ──────────────────────────────────────────────────

class TaGeneratedQuestionCard extends StatelessWidget {
  const TaGeneratedQuestionCard({super.key, required this.question});
  final ({
    String question,
    List<String> options,
    String answer,
    String explanation,
  })
  question;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final correctLetter = question.answer.trim().toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : taSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: taBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: taPrimary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: taPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Generated Question',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: taBorder),
                  ),
                  child: SelectableText(
                    question.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                if (question.options.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...question.options.map((option) {
                    final isCorrect =
                        option.trim().toUpperCase().startsWith(correctLetter) &&
                        question.options.length > 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? taPrimary.withValues(alpha: 0.1)
                            : isDark
                            ? Colors.grey[850]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCorrect ? taPrimary : taBorder,
                          width: isCorrect ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: isCorrect ? taPrimary : null,
                                fontWeight: isCorrect
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: taPrimary,
                              size: 18,
                            ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 12),
                // Correct answer row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: taSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: taSecondary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: taSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Correct Answer: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: taSecondary,
                        ),
                      ),
                      Text(
                        question.answer,
                        style: const TextStyle(color: taSecondary),
                      ),
                    ],
                  ),
                ),
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: taPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: taPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: taPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SelectableText(
                            question.explanation,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
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
    );
  }
}
