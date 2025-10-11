import 'package:flutter/material.dart';

class Announcement extends StatelessWidget {
  const Announcement({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8), // space between cards
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 0.1,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2A73FF),
          radius: 14,
          child: const Icon(Icons.campaign, color: Colors.white, size: 14),
        ),
        title: Text(
          'Mid term schedule released',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // add action later if needed
        },
      ),
    );
  }
}
