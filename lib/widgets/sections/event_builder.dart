import 'package:flutter/material.dart';
import 'package:student_systemv1/models/event.dart';
import 'package:student_systemv1/widgets/event_card.dart';

class EventBuilder extends StatelessWidget {
  EventBuilder({super.key});
  final List<FacultyEvent> eventList = [
    FacultyEvent(
      title: "AI and Machine Learning Workshop",
      location: "Hall A - Tech Building",
      date: "12 Oct 2025",
      image: 'assets/images/event.jpg',
    ),
    FacultyEvent(
      title: "Cybersecurity Awareness Session",
      location: "Main Auditorium",
      date: "15 Oct 2025",
      image: 'assets/images/event.jpg',
    ),
    FacultyEvent(
      title: "Hackathon 2025",
      location: "Innovation Lab",
      date: "22 Oct 2025",
      image: 'assets/images/event.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: eventList.length,
      itemBuilder: (context, index) {
        return Event(event: eventList[index]);
      },
    );
  }
}
