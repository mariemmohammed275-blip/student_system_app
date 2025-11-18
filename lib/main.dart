import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/widgets/forgetPassword_form.dart';
import 'package:student_systemv1/widgets/login_form.dart';
import 'package:student_systemv1/widgets/signUp_form.dart';
import 'package:student_systemv1/screens/main_screen.dart';
import 'package:student_systemv1/screens/splash_screen.dart';

void main() {
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
      getPages: [
        GetPage(name: '/login', page: () => const LoginForm()),
        GetPage(name: '/signup', page: () => const SignUpForm()),
        GetPage(name: '/home', page: () => MainScreen()),
        GetPage(name: '/forgot', page: () => const ForgotPasswordForm()),
      ],
    );
  }
}
