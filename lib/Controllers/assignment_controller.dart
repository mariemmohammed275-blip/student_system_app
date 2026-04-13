import 'package:get/get.dart';
import '../API/course_api.dart';
import '../models/assignment.dart';

class AssignmentsController extends GetxController {
  var assignments = <Assignment>[].obs;
  var isLoading = true.obs;

  // 1. ADD THE GUARD VARIABLE
  String? currentCourseId;

  Future<void> fetchAssignments(String courseId) async {
    // 2. THE GUARD: If we already have the data for this course, stop!
    if (currentCourseId == courseId) return;

    try {
      isLoading(true);
      currentCourseId = courseId; // Remember this course!

      final rawData = await CourseAPI.getCourseAssignments(courseId);
      assignments.assignAll(
        rawData.map((json) => Assignment.fromJson(json)).toList(),
      );
    } catch (e) {
      print("Error fetching assignments: $e");
    } finally {
      isLoading(false);
    }
  }
}
