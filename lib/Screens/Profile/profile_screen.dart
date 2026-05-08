import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_systemv1/API/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AuthService.currentStudent;

    // Check if the app is currently in Dark Mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        // Let the theme handle the AppBar background automatically
        backgroundColor: Colors.transparent,
        title: Text(
          "Profile",
          // Let the theme handle the text color automatically
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Icon color adapts to the theme automatically now
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage("assets/images/student.png"),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student?.fullName ?? "Student Name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Student ID: ${student?.studentId ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Year: ${student?.year ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "GPA Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Dynamically change card background
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    // Make shadows slightly darker in dark mode so they are visible
                    color: isDark ? Colors.black38 : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _GpaItem(label: "Current GPA", value: "3.67"),
                  _GpaItem(label: "Completed Hours", value: "92"),
                  _GpaItem(label: "Remaining", value: "38"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Dynamically change card background
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _InfoRow(title: "Email", value: student?.email ?? "N/A"),
                  const Divider(),
                  _InfoRow(title: "Phone", value: student?.phone ?? "N/A"),
                  const Divider(),
                  _InfoRow(
                    title: "Major",
                    value: student?.departmentName ?? "N/A",
                  ),
                  const Divider(),
                  const _InfoRow(title: "City", value: "Cairo"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Academic Advisor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Dynamically change card background
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("assets/images/advisor.png"),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. Keshk",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Computer and Systems Dept.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

class _GpaItem extends StatelessWidget {
  final String label;
  final String value;

  const _GpaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
