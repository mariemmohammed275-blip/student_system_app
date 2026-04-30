import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/API/attendance_api.dart';

class AttendanceRangeScreen extends StatefulWidget {
  const AttendanceRangeScreen({super.key});

  @override
  State<AttendanceRangeScreen> createState() => _AttendanceRangeScreenState();
}

class _AttendanceRangeScreenState extends State<AttendanceRangeScreen> {
  DateTime? from;
  DateTime? to;
  List<dynamic> data = [];
  bool loading = false;
  String errorMessage = "";

  String get courseId {
    final args = Get.arguments;
    if (args is Map) return args["courseId"]?.toString() ?? "";
    return args?.toString() ?? "";
  }

  String get courseName {
    final args = Get.arguments;
    if (args is Map) return args["courseName"]?.toString() ?? "Attendance";
    return "Attendance";
  }

  String _apiDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _displayDate(DateTime? date) {
    if (date == null) return "Select date";
    return _apiDate(date);
  }

  String _formatRecordDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? "");
    if (date == null) return value?.toString() ?? "";
    return _apiDate(date);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initialDate = isFrom ? from ?? now : to ?? from ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (selected == null) return;
    if (!mounted) return;

    setState(() {
      if (isFrom) {
        from = selected;
        if (to != null && to!.isBefore(selected)) to = selected;
      } else {
        to = selected;
      }
    });
  }

  Future<void> load() async {
    if (from == null || to == null) {
      setState(() => errorMessage = "Please select a start and end date.");
      return;
    }

    setState(() {
      loading = true;
      errorMessage = "";
    });

    try {
      final res = await AttendanceAPI.getRange(
        courseId,
        _apiDate(from!),
        _apiDate(to!),
      );

      if (!mounted) return;
      setState(() {
        data = res["data"] ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Unable to load attendance for this range.";
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xffF5F7FB),
      appBar: AppBar(
        title: Text("$courseName Range"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: "From",
                    value: _displayDate(from),
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: "To",
                    value: _displayDate(to),
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : load,
                icon: const Icon(Icons.search),
                label: const Text("Search"),
              ),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : data.isEmpty
                      ? const Center(child: Text("No records in this range."))
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, i) {
                            final record = data[i];
                            final status = record["status"]?.toString() ?? "";
                            final color = _statusColor(status);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.event_available, color: color),
                                title: Text(_formatRecordDate(record["date"])),
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
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        alignment: Alignment.centerLeft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
