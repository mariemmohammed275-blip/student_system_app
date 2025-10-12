import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/widgets/forgetPassword_form.dart';
import 'package:student_systemv1/widgets/login_form.dart';
import 'package:student_systemv1/widgets/signUp_form.dart';
import 'package:student_systemv1/screens/main_screen.dart';
import 'package:student_systemv1/screens/splash_screen.dart';
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student System',
      initialRoute: '/', // starting route
      getPages: [
        GetPage(name: '/', page: () => const AuthWrapper()),
        GetPage(name: '/login', page: () => const LoginForm()),
        GetPage(name: '/signup', page: () => const SignUpForm()),
        GetPage(name: '/home', page: () => MainScreen()),
        GetPage(name: '/forgot', page: () => const ForgotPasswordForm()),
      ],
    );
  }
}

// This widget listens to the auth state and navigates automatically
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          return MainScreen(); // logged in
        } else {
          return const LoginForm(); // not logged in
        }
      },
    );
  }
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:student_systemv1/widgets/forgetPassword_form.dart';
// import 'package:student_systemv1/widgets/login_form.dart';
// import 'package:student_systemv1/widgets/signUp_form.dart';
// import 'package:student_systemv1/screens/main_screen.dart';
// import 'package:student_systemv1/screens/splash_screen.dart';
// import 'package:student_systemv1/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       // theme: ThemeData(
//       //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       // ),
//       routes: {
//         "/": (context) => const LoginForm(),
//         "SignUpScreen": (context) => const SignUpForm(),
//         "HomeScreen": (context) => MainScreen(),
//         "ForgotPasswordForm": (context) => const ForgotPasswordForm(),
//       },
//     );
//   }
// }



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