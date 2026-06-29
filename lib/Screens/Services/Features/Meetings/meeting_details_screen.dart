import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/notification.dart';

class MeetingDetailsScreen extends StatelessWidget {
  final NotificationModel meeting;

  const MeetingDetailsScreen({super.key, required this.meeting});

  // Helper to format time (e.g., "1:00 PM")
  String formatTime(DateTime? date) {
    if (date == null) return "N/A";
    int hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    String period = date.hour >= 12 ? "PM" : "AM";
    return "$hour:${date.minute.toString().padLeft(2, '0')} $period";
  }

  Future<void> _launchMeeting(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      Get.snackbar("Error", "No meeting link provided.");
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not launch meeting.");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Parsing start and end times
    DateTime? start = meeting.startTime != null
        ? DateTime.tryParse(meeting.startTime!)
        : null;
    DateTime? end = meeting.endTime != null
        ? DateTime.tryParse(meeting.endTime!)
        : null;

    final Color cardColor = isDark
        ? Colors.grey[800]!
        : const Color(0xffE9EEF5);
    final Color iconColor = isDark
        ? Colors.blueAccent
        : const Color(0xff1c37d4);
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: const Text(
          "Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title.replaceAll("📹 New Meeting: ", ""),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meeting.courseName ?? "General Meeting",
                    style: TextStyle(
                      fontSize: 16,
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    Icons.person,
                    "Professor",
                    meeting.postedBy?['name'] ?? "Unknown",
                    iconColor,
                    textColor,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    Icons.access_time,
                    "Time",
                    "${formatTime(start)} - ${formatTime(end)}",
                    iconColor,
                    textColor,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem(
                    Icons.description,
                    "Description",
                    meeting.message,
                    iconColor,
                    textColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Join Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _launchMeeting(meeting.meetingUrl),
                child: const Text(
                  "Join Meeting Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color textColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
