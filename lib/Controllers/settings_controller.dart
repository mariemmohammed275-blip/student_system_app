import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // .obs makes these variables reactive! GetX will listen to them.
  var isDarkMode = false.obs;
  var isNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if the app is already in dark mode when the controller initializes
    isDarkMode.value = Get.isDarkMode;
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    // Instantly swaps the entire app's theme
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
    // TODO: Add any API calls here to save notification preferences later
  }
}
