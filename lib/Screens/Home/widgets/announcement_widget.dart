import 'package:flutter/material.dart';
import 'package:student_systemv1/models/notification.dart';
import 'package:student_systemv1/API/api_service.dart';

class Announcement extends StatelessWidget {
  const Announcement({super.key});

  // Helper method to fetch and merge both sources
  Future<List<NotificationModel>> fetchAllAnnouncements() async {
    // Run both API requests at the same time
    final results = await Future.wait([
      ApiService.getNotifications(),
      ApiService.getCourseAnnouncements(),
    ]);

    // Combine the lists
    List<NotificationModel> combined = [...results[0], ...results[1]];

    // Sort newest to oldest
    combined.sort((a, b) {
      DateTime dateA =
          DateTime.tryParse(a.createdAt) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      DateTime dateB =
          DateTime.tryParse(b.createdAt) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return combined;
  }

  Widget item(BuildContext context, NotificationModel notification) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        color: notification.seen
            ? (isDark ? Colors.grey[800] : Colors.white)
            : (isDark ? Colors.grey[850] : Colors.blue[50]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            // Change icon dynamically based on type if you want!
            notification.type == 'meeting' ? Icons.videocam : Icons.campaign,
            color: isDark
                ? Colors.blueAccent
                : const Color.fromARGB(255, 28, 55, 212),
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.title.isNotEmpty)
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  maxLines:
                      2, // Keeps UI clean if meeting descriptions are long
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
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
          const SizedBox(height: 5),
          FutureBuilder<List<NotificationModel>>(
            future:
                fetchAllAnnouncements(), // <-- Use the new fetch method here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Failed to load announcements."),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No new announcements.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final notifications = snapshot.data!.toList();

              return Column(
                children: notifications
                    .map((notif) => item(context, notif))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
