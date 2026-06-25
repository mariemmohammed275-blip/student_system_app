import 'package:flutter/material.dart';
import 'ta_theme.dart';

// ─── Tab Scaffold ─────────────────────────────────────────────────────────────

class TaTabScaffold extends StatelessWidget {
  const TaTabScaffold({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final child in children) ...[child, const SizedBox(height: 14)],
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class TaSectionTitle extends StatelessWidget {
  const TaSectionTitle({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

// ─── Input Card ───────────────────────────────────────────────────────────────

class TaInputCard extends StatelessWidget {
  const TaInputCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : taSoftBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: taBorder),
      ),
      child: child,
    );
  }
}

// ─── Output Card (simple text) ────────────────────────────────────────────────

class TaOutputCard extends StatelessWidget {
  const TaOutputCard({super.key, required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TaInputCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SelectableText(
            text.trim().isEmpty ? 'Output will appear here.' : text.trim(),
            style: TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segmented Choice Chips ───────────────────────────────────────────────────

class TaSegmentedChoices extends StatelessWidget {
  const TaSegmentedChoices({
    super.key,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((item) {
        final isSelected = value == item;
        return GestureDetector(
          onTap: () => onChanged(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? taPrimary
                  : isDark
                      ? Colors.grey[700]
                      : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? taPrimary : taBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.white70
                        : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class TaPrimaryButton extends StatelessWidget {
  const TaPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

// ─── Secondary Button ─────────────────────────────────────────────────────────

class TaSecondaryButton extends StatelessWidget {
  const TaSecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

// ─── Difficulty Badge ─────────────────────────────────────────────────────────

class TaBadge extends StatelessWidget {
  const TaBadge({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    Color bg, fg;
    if (lower.contains('easy')) {
      bg = taSecondary.withValues(alpha: 0.15);
      fg = taSecondary;
    } else if (lower.contains('medium')) {
      bg = taAccent.withValues(alpha: 0.15);
      fg = taAccent;
    } else if (lower.contains('hard')) {
      bg = Colors.red.withValues(alpha: 0.12);
      fg = Colors.red;
    } else {
      bg = taPrimary.withValues(alpha: 0.12);
      fg = taPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ─── Question Box (text field + button) ──────────────────────────────────────

class TaQuestionBox extends StatelessWidget {
  const TaQuestionBox({
    super.key,
    required this.controller,
    required this.label,
    required this.buttonLabel,
    required this.onPressed,
  });
  final TextEditingController controller;
  final String label;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TaInputCard(
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: label),
          ),
          const SizedBox(height: 12),
          TaPrimaryButton(label: buttonLabel, icon: Icons.search, onPressed: onPressed),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String taBadgeLabel(String level) {
  switch (level.toLowerCase()) {
    case 'easy':   return 'Easy';
    case 'medium': return 'Medium';
    case 'hard':   return 'Hard';
    default:       return level;
  }
}
