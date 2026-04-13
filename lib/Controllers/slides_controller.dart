import 'package:get/get.dart';
import '../API/course_api.dart';
import '../models/course_material.dart'; // Import your new model

class SlidesController extends GetxController {
  // Now it holds a clean List of CourseMaterial objects!
  var slides = <CourseMaterial>[].obs;
  var isLoading = true.obs;

  // 1. THE GUARD VARIABLE
  String? currentCourseId;

  Future<void> fetchSlides(String courseId) async {
    // 2. THE GUARD: Stop if we already downloaded this course's materials!
    if (currentCourseId == courseId) return;

    try {
      isLoading(true);
      currentCourseId = courseId; // Remember this course

      // Assuming your API call is something like this:
      final rawData = await CourseAPI.getCourseSlides(courseId);

      // Convert the raw JSON maps into our CourseMaterial model
      slides.assignAll(
        rawData.map((json) => CourseMaterial.fromJson(json)).toList(),
      );
    } catch (e) {
      print("Error fetching slides: $e");
    } finally {
      isLoading(false);
    }
  }
}
