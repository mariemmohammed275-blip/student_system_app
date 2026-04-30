import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Features/Attendance/screens/attendance_summary_screen.dart';
import 'Features/Exams/exams.dart';
import 'Features/Grades/grades_page.dart';
import 'Features/SelectedCourses/selected_courses.dart';
import 'Features/CourseEnrollment/course_enrollment.dart';
import 'Features/OnlineMeeting/online_meeting.dart';
import 'Features/Payments/payments.dart';
import 'Features/Schedules/schedules.dart';

class ServicesScreen extends StatelessWidget {
  ServicesScreen({
    super.key,
  }); // Added a const constructor key for best practices

  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.qr_code,
      'title': 'Attendance Details',
      'page': () => AttendanceSummaryScreen(),
    },
    {
      'icon': Icons.schedule_sharp,
      'title': 'Schedules',
      'page': () => Schedules(), // Removed const
    },
    {
      'icon': Icons.quiz,
      'title': 'Exams & Results',
      'page': () => Exams(),
    }, // Removed const
    {
      'icon': Icons.payment,
      'title': 'Payment',
      'page': () => Payments(),
    }, // Removed const
    {
      'icon': Icons.grade_rounded,
      'title': 'Grades',
      'page': () => Grades(),
    }, // Removed const
    {
      'icon': Icons.video_call,
      'title': 'Online Meeting',
      'page': () => OnlineMeeting(), // Removed const
    },
    {
      'icon': Icons.book,
      'title': 'Courses',
      'page': () => SelectedCourses(),
    }, // Removed const
    {
      'icon': Icons.add_circle_outline,
      'title': 'Course Enrollment',
      'page': () => CourseEnrollment(), // Removed const
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Check if the app is currently in Dark Mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 2. Adjust Scaffold Background dynamically
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,

      appBar: AppBar(
        elevation: 0,
        // 3. Make AppBar transparent so it matches the Scaffold background
        backgroundColor: Colors.transparent,
        title: Text(
          "Services",
          style: TextStyle(
            // 4. Adapt text color to theme automatically
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final service = services[index];

            return GestureDetector(
              onTap: () {
                Get.to(service['page']);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  // 5. Change Card color from light blue to dark grey in Dark Mode
                  color: isDark ? Colors.grey[800] : const Color(0xffE9EEF5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔵 icon circle
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        service['icon'],
                        // 6. Brighten the blue icon in Dark Mode so it's easily visible
                        color: isDark
                            ? Colors.blueAccent
                            : const Color.fromARGB(255, 28, 55, 212),
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 📝 title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        service['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Font color handles itself automatically based on the theme!
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
