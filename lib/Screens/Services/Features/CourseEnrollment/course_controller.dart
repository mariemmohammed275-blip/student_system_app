import 'package:get/get.dart';
import 'package:student_systemv1/API/auth_service.dart';
import 'package:student_systemv1/API/course_api.dart';

class CourseController extends GetxController {
  var allCourses = <Map<String, dynamic>>[].obs;
  var selectedCourses = <Map<String, dynamic>>[].obs;

  String studentId = AuthService.currentStudent?.id ?? "";

  // Load all courses from API
  Future<void> fetchCourses() async {
    try {
      studentId = AuthService.currentStudent?.id ?? "";

      final data = await CourseAPI.getAllCourses();
      allCourses.assignAll(data);

      // Mark courses already enrolled
      selectedCourses.assignAll(
        allCourses
            .where(
              (course) =>
                  AuthService.currentStudent?.courses.contains(course["_id"]) ??
                  false,
            )
            .toList(),
      );
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
