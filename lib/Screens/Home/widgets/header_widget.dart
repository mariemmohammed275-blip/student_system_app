import 'package:flutter/material.dart';
import 'package:student_systemv1/API/auth_service.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final student = AuthService.currentStudent;
    final name = student?.fullName ?? "Student";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const CircleAvatar(
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
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  // Let the theme handle the text color automatically!
                ),
              ),
              const Text(
                'Good Morning',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey, // Grey is usually fine in both modes
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.notifications,
              // REMOVED Colors.black here. Now it will be black in light mode, white in dark mode.
              color: Theme.of(context).iconTheme.color,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
