import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'code_assesstent/code_assesstent_button.dart';
import 'teaching_assesstent/teaching_assesstent_button.dart';

class AiFeaturesScreen extends StatelessWidget {
  const AiFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[800] : const Color(0xffE9EEF5);
    final primaryColor = isDark
        ? Colors.blueAccent
        : const Color.fromARGB(255, 28, 55, 212);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        title: const Text(
          'AI Features',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TeachingAssesstentButton(
                cardColor: cardColor,
                primaryColor: primaryColor,
                subtitleColor: subtitleColor,
              ),
              const SizedBox(height: 14),
              CodeAssesstentButton(
                cardColor: cardColor,
                primaryColor: primaryColor,
                subtitleColor: subtitleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
