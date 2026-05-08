import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:student_systemv1/Authentication/forgetPassword_form.dart';
import 'package:student_systemv1/Authentication/login_form.dart';
import 'package:student_systemv1/Authentication/signUp_form.dart';
import 'package:student_systemv1/Screens/main_screen.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_course_history_screen.dart';
import 'package:student_systemv1/Screens/Services/Features/Attendance/screens/attendance_range_screen.dart';

import 'Screens/Services/Features/CourseEnrollment/course_controller.dart';

void main() {
  Get.put(CourseController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student System',
      initialRoute: '/login',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ), // Standardized light bg
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ), // Standardized dark bg
      themeMode: ThemeMode.light,

      builder: (context, child) {
        // This universally forces the status bar text/icons to match the theme!
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: child!,
        );
      },
      getPages: [
        GetPage(name: '/login', page: () => const LoginForm()),
        GetPage(name: '/signup', page: () => const SignUpForm()),
        GetPage(name: '/home', page: () => MainScreen()),
        GetPage(name: '/forgot', page: () => const ForgotPasswordForm()),
        GetPage(
          name: '/attendance-course-history',
          page: () => const AttendanceCourseHistoryScreen(),
        ),
        GetPage(
          name: '/attendance-range',
          page: () => const AttendanceRangeScreen(),
        ),
      ],
    );
  }
}
