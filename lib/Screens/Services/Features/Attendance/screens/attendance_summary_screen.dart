import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/attendance_controller.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_course_history_screen.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_range_screen.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  AttendanceSummaryScreen({super.key});

  final AttendanceController controller = Get.put(AttendanceController());

  Color _progressColor(double percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : const Color(0xffF5F7FB);
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Attendance Summary"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadSummary,
          );
        }

        if (controller.courses.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.loadSummary,
            child: ListView(
              children: const [
                SizedBox(height: 180),
                Center(child: Text("No attendance available.")),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadSummary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.warnings.isNotEmpty)
                _WarningsPanel(
                  warnings: controller.warnings,
                  cardColor: cardColor,
                ),
              ...controller.courses.map((course) {
                final progressColor = _progressColor(course.percentage);

                return Card(
                  color: cardColor,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.courseName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              "${course.percentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: progressColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (course.percentage / 100)
                                .clamp(0.0, 1.0)
                                .toDouble(),
                            minHeight: 9,
                            color: progressColor,
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _StatChip(
                              label: "Present",
                              value: course.present.toString(),
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: "Absent",
                              value: course.absent.toString(),
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: "Lectures",
                              value: course.totalLectures.toString(),
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => const AttendanceCourseHistoryScreen(),
                                    arguments: {
                                      "courseId": course.courseId,
                                      "courseName": course.courseName,
                                    },
                                  );
                                },
                                icon: const Icon(Icons.history),
                                label: const Text("History"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => const AttendanceRangeScreen(),
                                    arguments: {
                                      "courseId": course.courseId,
                                      "courseName": course.courseName,
                                    },
                                  );
                                },
                                icon: const Icon(Icons.date_range),
                                label: const Text("Range"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

class _WarningsPanel extends StatelessWidget {
  const _WarningsPanel({required this.warnings, required this.cardColor});

  final List<Map<String, dynamic>> warnings;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "Attendance Warnings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "${warning["courseName"]}: ${warning["percentage"]}%",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Try again")),
          ],
        ),
      ),
    );
  }
}
