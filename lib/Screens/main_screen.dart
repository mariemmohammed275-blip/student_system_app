import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'Home/home_screen.dart';
import 'Services/services_screen.dart';
import 'Community/community_screen.dart';
import 'Profile/profile_screen.dart';
import 'Setting/settings_screen.dart';

// Controller to manage navigation state
class NavController extends GetxController {
  var selectedIndex = 0.obs;

  final screens = [
    () => const HomeScreen(),
    () => ServicesScreen(),
    () => const CommunityScreen(),
    () => const ProfileScreen(),
    () => const SettingsScreen(),
  ];
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final NavController navController = Get.put(NavController());

  Widget navItem(IconData icon, String label, int index) {
    final isSelected = navController.selectedIndex.value == index;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Colors.white : Colors.black54,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: navController.screens[navController.selectedIndex.value](),

        bottomNavigationBar: CurvedNavigationBar(
          index: navController.selectedIndex.value,
          backgroundColor: Colors.transparent,
          color: Colors.white,
          buttonBackgroundColor: const Color(0xFF2A73FF),
          height: 70,
          animationDuration: const Duration(milliseconds: 300),

          items: [
            navItem(Icons.home_outlined, "Home", 0),
            navItem(Icons.miscellaneous_services_outlined, "Services", 1),
            navItem(Icons.people_outline, "Community", 2),
            navItem(Icons.person_outline, "Profile", 3),
            navItem(Icons.settings_outlined, "Settings", 4),
          ],

          onTap: (index) {
            navController.selectedIndex.value = index;
          },
        ),
      ),
    );
  }
}
