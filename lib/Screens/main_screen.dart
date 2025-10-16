import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_screen.dart';
import 'services_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

// Controller to manage navigation state
class NavController extends GetxController {
  var selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const ServicesScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final NavController navController = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: navController.screens[navController.selectedIndex.value],

        bottomNavigationBar: CurvedNavigationBar(
          index: navController.selectedIndex.value,
          backgroundColor: Colors.transparent,
          color: Colors.white,
          buttonBackgroundColor: const Color(0xFF2A73FF),
          height: 60,
          animationDuration: const Duration(milliseconds: 300),
          items: const [
            Icon(Icons.home_outlined, size: 30, color: Colors.black),
            Icon(
              Icons.miscellaneous_services_outlined,
              size: 30,
              color: Colors.black,
            ),
            Icon(Icons.people_outline, size: 30, color: Colors.black),
            Icon(Icons.person_outline, size: 30, color: Colors.black),
            Icon(Icons.settings_outlined, size: 30, color: Colors.black),
          ],
          onTap: (index) {
            navController.selectedIndex.value = index;
          },
        ),
      ),
    );
  }
}
