import 'package:flutter/material.dart';
import 'package:student_systemv1/models/notification.dart';
import 'package:student_systemv1/API/api_service.dart';

class Announcement extends StatelessWidget {
  const Announcement({super.key});

  Widget item(BuildContext context, NotificationModel notification) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        // Soften the border in dark mode
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        // If the notification is unseen, give it a slightly highlighted background
        color: notification.seen
            ? (isDark ? Colors.grey[800] : Colors.white)
            : (isDark ? Colors.grey[850] : Colors.blue[50]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign,
            // Brighten the blue icon in dark mode so it pops
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
            // Adjust arrow color
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
            future: ApiService.getNotifications(),
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

              // Take only the top 3 notifications to avoid cluttering the home screen
              final notifications = snapshot.data!.take(3).toList();

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
