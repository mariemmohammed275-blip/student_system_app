import 'package:flutter/material.dart';

class Announcement extends StatelessWidget {
  const Announcement({super.key});

  Widget item(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.campaign,
            color: Color.fromARGB(255, 28, 55, 212),
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          const Icon(Icons.arrow_forward_ios, size: 14),
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
          item("Midterm schedule released"),
          item("Library open till 8PM today"),
        ],
      ),
    );
  }
}
