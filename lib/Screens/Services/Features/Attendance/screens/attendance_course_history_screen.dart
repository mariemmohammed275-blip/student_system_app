import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/API/attendance_api.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_range_screen.dart';

class AttendanceCourseHistoryScreen extends StatefulWidget {
  const AttendanceCourseHistoryScreen({super.key});

  @override
  State<AttendanceCourseHistoryScreen> createState() =>
      _AttendanceCourseHistoryScreenState();
}

class _AttendanceCourseHistoryScreenState
    extends State<AttendanceCourseHistoryScreen> {
  bool loading = true;
  String errorMessage = "";
  List<dynamic> data = [];
  Map<String, dynamic> summary = {};

  String get courseId {
    final args = Get.arguments;
    if (args is Map) return args["courseId"]?.toString() ?? "";
    return args?.toString() ?? "";
  }

  String get courseName {
    final args = Get.arguments;
    if (args is Map) return args["courseName"]?.toString() ?? "Course";
    return "Course";
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final response = await AttendanceAPI.getCourseHistory(courseId);

      if (!mounted) return;
      setState(() {
        data = response["data"] ?? [];
        summary = Map<String, dynamic>.from(response["summary"] ?? {});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Unable to load course attendance.";
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green;
      case "Late":
        return Colors.orange;
      case "Excused":
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Present":
        return Icons.check_circle;
      case "Late":
        return Icons.schedule;
      case "Excused":
        return Icons.info;
      default:
        return Icons.cancel;
    }
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "");
    if (date == null) return value?.toString() ?? "";

    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text(courseName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(
                () => const AttendanceRangeScreen(),
                arguments: {"courseId": courseId, "courseName": courseName},
              );
            },
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _ErrorState(message: errorMessage, onRetry: load)
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _SummaryHeader(summary: summary),
                      const SizedBox(height: 12),
                      if (data.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 140),
                          child: Center(child: Text("No attendance records")),
                        )
                      else
                        ...data.map((record) {
                          final status = record["status"]?.toString() ?? "";
                          final color = _statusColor(status);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _statusIcon(status),
                                color: color,
                              ),
                              title: Text(_formatDate(record["date"])),
                              subtitle: Text("Status: $status"),
                              trailing: Text(
                                status,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summary});

  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SummaryItem(label: "Present", value: "${summary["Present"] ?? 0}"),
            _SummaryItem(label: "Absent", value: "${summary["Absent"] ?? 0}"),
            _SummaryItem(label: "Late", value: "${summary["Late"] ?? 0}"),
            _SummaryItem(
              label: "Percent",
              value: "${summary["percentage"] ?? 0}%",
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
