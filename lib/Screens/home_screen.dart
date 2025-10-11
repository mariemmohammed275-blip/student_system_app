import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth
      .instance
      .currentUser!; //بحفظ بيانات المستخدم الي عامل تسجيل دخول حاليا
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello you are Signed in", style: TextStyle(fontSize: 22.0)),
            Text(user.email!, style: TextStyle(fontSize: 22.0)),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed("/");
              },
              color: Colors.blue,
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
