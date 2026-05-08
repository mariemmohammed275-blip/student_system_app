import 'package:flutter/material.dart';
import 'package:student_systemv1/Screens/Home/widgets/announcement_widget.dart';
import 'package:student_systemv1/Screens/Home/widgets/quick_actions.dart';
import 'package:student_systemv1/Screens/Home/widgets/schedule.dart';
import 'package:student_systemv1/Screens/Home/widgets/sections/event_builder.dart';
import 'widgets/header_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Header(),
                SizedBox(height: 30),
                QuickActions(),
                SizedBox(height: 15),
                Announcement(),
                SizedBox(height: 30),
                Schedule(),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontFamily: 'Robot',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(height: 260, child: EventBuilder()),
                SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
