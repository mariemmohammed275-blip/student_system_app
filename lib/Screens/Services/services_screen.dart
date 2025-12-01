import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Features/Exams/exams.dart';
import 'Features/SelectedCourses/selected_courses.dart';
import 'Features/Attendance/attendance.dart';
import 'Features/CourseEnrollment/course_enrollment.dart';
import 'Features/OnlineMeeting/online_meeting.dart';
import 'Features/Payments/payments.dart';
import 'Features/Schedules/schedules.dart';

class ServicesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.qr_code,
      'title': 'Attendance Details',
      'page': () => Attendance(),
    },
    {'icon': Icons.school, 'title': 'Schedules', 'page': () => Schedules()},
    {'icon': Icons.quiz, 'title': 'Exams & Results', 'page': () => Exams()},
    {'icon': Icons.payment, 'title': 'Payment', 'page': () => Payments()},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Services'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: () {
                Get.to(service['page']);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors
                          .primaries[index % Colors.primaries.length]
                          .shade200,
                      Colors
                          .primaries[index % Colors.primaries.length]
                          .shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service['icon'], size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      service['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
