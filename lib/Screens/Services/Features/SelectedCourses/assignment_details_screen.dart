import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/models/assignment.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  final Assignment assignment;

  const AssignmentDetailsScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Assignment Details",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER (Title & Due Date)
            Text(
              assignment.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  "Due: ${assignment.formattedDeadline}",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
            const SizedBox(height: 20),

            // 2. INSTRUCTIONS / DESCRIPTION
            Text(
              "Instructions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              assignment.description,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // 3. PROFESSOR'S ATTACHMENT (Only shows if a file exists)
            if (assignment.fullFileUrl.isNotEmpty) ...[
              Text(
                "Reference Material",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: isDark ? Colors.grey[800] : Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red[900]?.withOpacity(0.3)
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.redAccent,
                    ),
                  ),
                  title: Text(
                    "Download Assignment File",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.download_rounded,
                    color: isDark ? Colors.blueAccent : Colors.blue,
                  ),
                  onTap: () async {
                    final uri = Uri.parse(assignment.fullFileUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],

            Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
            const SizedBox(height: 20),

            // 4. UPLOAD SECTION
            Text(
              "Your Submission",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            // Upload Box
            GestureDetector(
              onTap: () {
                // TODO: Trigger file picker here!
                Get.snackbar(
                  "Coming Soon",
                  "We will connect the file picker here next!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  colorText: isDark ? Colors.white : Colors.black,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.blue[200]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 50,
                      color: isDark ? Colors.blueAccent : Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tap to upload your answer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.blueAccent : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Supports PDF, DOCX, ZIP",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
