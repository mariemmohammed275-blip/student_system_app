import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_systemv1/Screens/Widgets/forgetPassword_form.dart';
import 'package:student_systemv1/Screens/Widgets/login_form.dart';
import 'package:student_systemv1/Screens/Widgets/signUp_form.dart';
import 'package:student_systemv1/Screens/home_screen.dart';
import 'package:student_systemv1/Screens/splash_screen.dart';
import 'package:student_systemv1/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),
      routes: {
        "/": (context) => const LoginForm(),
        "SignUpScreen": (context) => const SignUpForm(),
        "HomeScreen": (context) => const HomeScreen(),
        "ForgotPasswordForm": (context) => const ForgotPasswordForm(),
      },
    );
  }
}



//home: StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: ((context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const SplashScreen();
      //     }

      //     if (snapshot.hasData) {
      //       return const HomeScreen();
      //     } else {
      //       return AuthScreen();
      //     }
      //   }),
      // ),