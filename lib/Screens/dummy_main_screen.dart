import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'services_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2A73FF),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.to(() => const HomeScreen(), transition: Transition.fadeIn);
              break;
            case 1:
              Get.to(
                () => const ServicesScreen(),
                transition: Transition.fadeIn,
              );
              break;
            case 2:
              Get.to(
                () => const CommunityScreen(),
                transition: Transition.fadeIn,
              );
              break;
            case 3:
              Get.to(
                () => const ProfileScreen(),
                transition: Transition.fadeIn,
              );
              break;
            case 4:
              Get.to(
                () => const SettingsScreen(),
                transition: Transition.fadeIn,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services_outlined),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
