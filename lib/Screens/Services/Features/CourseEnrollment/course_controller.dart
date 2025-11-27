import 'package:get/get.dart';
import 'package:student_systemv1/API/course_api.dart';

class CourseController extends GetxController {
  var allCourses = <Map<String, dynamic>>[].obs;
  var selectedCourses = <Map<String, dynamic>>[].obs;

  String studentId = "69282ab6d8f3220b9d2dc15a"; // ← هتجيبيها بعد اللوجين

  // Load all courses from API
  Future<void> fetchCourses() async {
    try {
      final data = await CourseAPI.getAllCourses();
      allCourses.assignAll(data);
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  // Check if course already added
  bool isAdded(String id) {
    return selectedCourses.any((c) => c["_id"] == id);
  }

  // Add course locally + send to API
  Future<void> addCourse(Map<String, dynamic> course) async {
    if (isAdded(course["_id"])) return;

    bool success = await CourseAPI.enrollCourse(
      studentId: studentId,
      courseId: course["_id"],
    );

    if (success) {
      selectedCourses.add(course);
    }
    print("studentId = $studentId");
    print("courseId = ${course["_id"]}");
  }
}
