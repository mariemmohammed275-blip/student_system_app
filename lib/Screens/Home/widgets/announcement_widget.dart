import 'package:flutter/material.dart';

class Announcement extends StatelessWidget {
  const Announcement({super.key});

  // Added context so the item knows if it's in dark mode
  Widget item(BuildContext context, String text) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        // Soften the border in dark mode
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
        ),
        // Switch background color
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign,
            // Brighten the blue icon in dark mode so it pops
            color: isDark
                ? Colors.blueAccent
                : const Color.fromARGB(255, 28, 55, 212),
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            // Adjust arrow color
            color: isDark ? Colors.grey[400] : Colors.black54,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Announcements",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Poppins',
            ),
          ),
          // Pass context to the items
          item(context, "Midterm schedule released"),
          item(context, "Library open till 8PM today"),
        ],
      ),
    );
  }
}
