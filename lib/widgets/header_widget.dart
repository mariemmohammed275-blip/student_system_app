import 'package:flutter/material.dart';
import 'package:student_systemv1/services/auth_service.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AuthService.currentStudent; // get logged-in student
    final name = student?.fullName ?? "Student";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg',
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Good Morning',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.black, // Set the color of the bell icon
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
