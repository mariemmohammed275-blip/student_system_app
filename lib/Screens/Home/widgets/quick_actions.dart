import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  final Color cardColor = const Color(0xffE9EEF5);

  Widget actionItem({required IconData icon, required String title}) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔵 icon circle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xffDDE5F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Color.fromARGB(255, 28, 55, 212),
                size: 22,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Robot',
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
              fontFamily: 'Robot',
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              actionItem(icon: Icons.school, title: "Grades"),
              actionItem(icon: Icons.qr_code, title: "QR Attendance"),
              actionItem(icon: Icons.account_balance_wallet, title: "Payments"),
            ],
          ),
        ],
      ),
    );
  }
}
