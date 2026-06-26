import 'package:flutter/material.dart';
import 'package:student_systemv1/models/event.dart';
import 'package:student_systemv1/API/api_service.dart';
import 'package:student_systemv1/Screens/Home/widgets/event_card.dart';

class EventBuilder extends StatelessWidget {
  const EventBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FacultyEvent>>(
      future: ApiService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading events"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No upcoming events"));
        }

        final eventList = snapshot.data!;

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: eventList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // You can add navigation to an Event Details screen here
              },
              child: Event(event: eventList[index]),
            );
          },
        );
      },
    );
  }
}
