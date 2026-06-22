import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'code_assesstent_screen.dart';

class CodeAssesstentButton extends StatelessWidget {
  const CodeAssesstentButton({
    super.key,
    required this.cardColor,
    required this.primaryColor,
    required this.subtitleColor,
  });

  final Color? cardColor;
  final Color primaryColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Get.to(() => const CodeAssesstentScreen()),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.code_rounded, color: primaryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code Assistant',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Get help with code, errors, and explanations.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
