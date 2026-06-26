import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_qr_scan_screen.dart';
import 'package:student_systemv1/Screens/Services/Features/Grades/grades_screen.dart';
import 'package:student_systemv1/Screens/Services/Features/Payments/payments_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Widget actionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : const Color(0xffE9EEF5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDark
                    ? Colors.blueAccent
                    : const Color.fromARGB(255, 28, 55, 212),
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontFamily: 'Roboto'),
              ),
            ],
          ),
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
              // 👇 Added onTap and imported Grades()
              actionItem(
                context: context,
                icon: Icons.school,
                title: "Grades",
                onTap: () => Get.to(() => Grades()),
              ),
              actionItem(
                context: context,
                icon: Icons.qr_code_scanner,
                title: "QR\nAttendance",
                onTap: () => Get.to(() => const AttendanceQrScanScreen()),
              ),
              // 👇 Added onTap and imported Payments()
              actionItem(
                context: context,
                icon: Icons.account_balance_wallet,
                title: "Payments",
                onTap: () => Get.to(() => Payments()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
