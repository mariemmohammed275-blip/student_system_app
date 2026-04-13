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
    () => SettingsScreen(),
  ];
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final NavController navController = Get.put(NavController());

  // 1. Pass BuildContext into the navItem so it can check the theme
  Widget navItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = navController.selectedIndex.value == index;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            // 2. White if selected (since it's on the blue button).
            // If unselected, switch between black54 (Light) and light grey (Dark)
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              // 3. Apply the same logic to the text
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 4. Check if we are in Dark Mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: navController.screens[navController.selectedIndex.value](),

        bottomNavigationBar: CurvedNavigationBar(
          index: navController.selectedIndex.value,
          backgroundColor: Colors.transparent,

          // 5. Change the main Navigation Bar color dynamically!
          color: isDark ? Colors.grey[900]! : Colors.white,

          // The selected "floating" button stays blue because it looks great in both themes
          buttonBackgroundColor: const Color(0xFF2A73FF),
          height: 70,
          animationDuration: const Duration(milliseconds: 300),

          items: [
            // Pass the context to all nav items
            navItem(context, Icons.home_outlined, "Home", 0),
            navItem(
              context,
              Icons.miscellaneous_services_outlined,
              "Services",
              1,
            ),
            navItem(context, Icons.people_outline, "Community", 2),
            navItem(context, Icons.person_outline, "Profile", 3),
            navItem(context, Icons.settings_outlined, "Settings", 4),
          ],

          onTap: (index) {
            navController.selectedIndex.value = index;
          },
        ),
      ),
    );
  }
}
