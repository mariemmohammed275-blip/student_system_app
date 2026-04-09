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
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.qr_code,
      'title': 'Attendance Details',
      'page': () => AttendanceSummaryScreen(),
    },
    {
      'icon': Icons.schedule_sharp,
      'title': 'Schedules',
      'page': () => Schedules(),
    },
    {'icon': Icons.quiz, 'title': 'Exams & Results', 'page': () => Exams()},
    {'icon': Icons.payment, 'title': 'Payment', 'page': () => Payments()},
    {'icon': Icons.grade_rounded, 'title': 'Grades', 'page': () => Grades()},
    {
      'icon': Icons.video_call,
      'title': 'Online Meeting',
      'page': () => OnlineMeeting(),
    },
    {'icon': Icons.book, 'title': 'Courses', 'page': () => SelectedCourses()},
    {
      'icon': Icons.add_circle_outline,
      'title': 'Course Enrollment',
      'page': () => CourseEnrollment(),
    },
  ];

  final Color cardColor = const Color(0xffE9EEF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffF5F7FB),
        title: const Text(
          "Services",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
                  color: cardColor,
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
                        color: const Color.fromARGB(255, 28, 55, 212),
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
