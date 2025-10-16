import 'package:flutter/material.dart';
import 'package:student_systemv1/widgets/announcement_widget.dart';
import 'package:student_systemv1/widgets/sections/event_builder.dart';
import 'package:student_systemv1/widgets/sections/recent_news_builder.dart';
import '../widgets/header_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Student's Portal",
            style: TextStyle(fontFamily: 'Roboto'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Header(),
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
              GestureDetector(
                onTap: () {},
                child: SizedBox(height: 260, child: EventBuilder()),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Announcements',
                  style: TextStyle(
                    fontFamily: 'Robot',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Announcement(),
              Announcement(),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent News',
                  style: TextStyle(
                    fontFamily: 'Robot',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(height: 350, child: RecentNewsBuilder()),
            ],
          ),
        ),
      ),
    );
  }
}
