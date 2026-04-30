import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Widget actionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    // Check if Dark Mode is active
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          // Dynamically change the background color
          color: isDark ? Colors.grey[800] : const Color(0xffE9EEF5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔵 icon circle
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                // Dynamically change the circle color
                color: isDark ? Colors.grey[800] : const Color(0xffE9EEF5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                // Keep the blue icon, or change it if you prefer in dark mode
                color: isDark
                    ? Colors.blueAccent
                    : const Color.fromARGB(255, 28, 55, 212),
                size: 30,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Pass context so the items know the current theme
              actionItem(context: context, icon: Icons.school, title: "Grades"),
              actionItem(
                context: context,
                icon: Icons.qr_code,
                title: "\t       QR \n Attendance",
              ),
              actionItem(
                context: context,
                icon: Icons.account_balance_wallet,
                title: "Payments",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
