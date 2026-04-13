import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../API/course_api.dart';

class AssignmentDetailsController extends GetxController {
  var isUploading = false.obs;

  // NEW: State variables to hold the file name and success status
  var selectedFileName = ''.obs;
  var isUploaded = false.obs;

  Future<void> pickAndUploadFile(String assignmentId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
      );

      if (result != null && result.files.single.path != null) {
        // 1. Save the file name to show in the UI immediately
        String filePath = result.files.single.path!;
        selectedFileName.value = result.files.single.name;

        // 2. Start loading spinner
        isUploading.value = true;
        isUploaded.value = false;

        // 3. Upload to API
        bool success = await CourseAPI.submitAssignment(
          assignmentId: assignmentId,
          filePath: filePath,
          fileName: selectedFileName.value,
        );

        isUploading.value = false;

        // 4. Update the UI state based on success or failure
        if (success) {
          isUploaded.value = true; // This will trigger the green checkmark UI!
          Get.snackbar(
            "Success!",
            "Your assignment has been submitted successfully.",
            backgroundColor: Colors.green[600],
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        } else {
          selectedFileName.value = ''; // Clear it if upload fails
          Get.snackbar(
            "Error",
            "Failed to upload assignment. Please try again.",
            backgroundColor: Colors.red[600],
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e) {
      isUploading.value = false;
      print("Error picking file: $e");
    }
  }
}
