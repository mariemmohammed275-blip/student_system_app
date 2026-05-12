import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_qr_scan_screen.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_summary_screen.dart';

class AttendanceDetailsScreen extends StatelessWidget {
  const AttendanceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : const Color(0xffF5F7FB);
    final foregroundColor = isDark ? Colors.white : const Color(0xff172033);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        // systemOverlayStyle: isDark
        //     ? SystemUiOverlayStyle.light
        //     : SystemUiOverlayStyle.dark,
        //title: const Text("Attendance Details"),
        //centerTitle: true,
        //elevation: 0,
        //backgroundColor: Colors.transparent,
        //foregroundColor: foregroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 5, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xff152033)
                      : const Color(0xff163B88),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    _HeaderIcon(),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attendance details",

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                "Actions",
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _AttendanceActionButton(
                icon: Icons.fact_check_outlined,
                title: "Attendance Summary",
                accentColor: const Color(0xff1D6FE8),
                onTap: () => Get.to(() => AttendanceSummaryScreen()),
              ),
              const SizedBox(height: 12),
              _AttendanceActionButton(
                icon: Icons.qr_code_scanner,
                title: "Scan QR",
                accentColor: const Color(0xff168A68),
                onTap: () => Get.to(() => const AttendanceQrScanScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(42)),
      ),
      child: const Icon(
        Icons.how_to_reg_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _AttendanceActionButton extends StatelessWidget {
  const _AttendanceActionButton({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xff172033);

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(20)
                  : const Color(0xffE1E7F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
