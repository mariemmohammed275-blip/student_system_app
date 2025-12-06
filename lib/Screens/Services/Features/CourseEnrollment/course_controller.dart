import 'package:get/get.dart';
import 'package:student_systemv1/API/auth_service.dart';
import 'package:student_systemv1/API/course_api.dart';

class CourseController extends GetxController {
  var allCourses = <Map<String, dynamic>>[].obs;
  var selectedCourses = <Map<String, dynamic>>[].obs;
  var unenrolledCourses = <Map<String, dynamic>>[].obs;

  String studentId = AuthService.currentStudent?.id ?? "";
  List<String> studentCourseIds = AuthService.currentStudent?.courses ?? [];

  /// Fetch all courses from API and separate enrolled vs unenrolled
  Future<void> fetchCourses() async {
    try {
      // Current student info
      studentId = AuthService.currentStudent?.id ?? "";
      studentCourseIds = AuthService.currentStudent?.courses ?? [];

      // Fetch all courses from API
      final data =
          await CourseAPI.getAllCourses(); // <--- make sure this returns ALL courses
      allCourses.assignAll(data);

      // Courses student already enrolled in
      selectedCourses.assignAll(
        allCourses
            .where((course) => studentCourseIds.contains(course["_id"]))
            .toList(),
      );

      // Courses student has NOT enrolled in yet
      unenrolledCourses.assignAll(
        allCourses
            .where((course) => !studentCourseIds.contains(course["_id"]))
            .toList(),
      );

      print(
        "All courses from API: ${allCourses.map((c) => c["name"]).toList()}",
      );
      print("Student enrolled courses: $studentCourseIds");
      print(
        "Selected courses: ${selectedCourses.map((c) => c["name"]).toList()}",
      );
      print(
        "Unenrolled courses: ${unenrolledCourses.map((c) => c["name"]).toList()}",
      );
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

  /// Check if a course is already added
  bool isAdded(String id) {
    return selectedCourses.any((c) => c["_id"] == id);
  }

  /// Enroll student in a course
  Future<void> addCourse(Map<String, dynamic> course) async {
    if (isAdded(course["_id"])) return;

    bool success = await CourseAPI.enrollCourse(
      studentId: studentId,
      courseId: course["_id"],
    );

    if (success) {
      // Update currentStudent using copyWith
      final updatedCourses = List<String>.from(
        AuthService.currentStudent!.courses,
      )..add(course["_id"]);
      AuthService.currentStudent = AuthService.currentStudent!.copyWith(
        courses: updatedCourses,
      );

      // Update local lists
      selectedCourses.add(course);
      unenrolledCourses.removeWhere((c) => c["_id"] == course["_id"]);
      studentCourseIds.add(course["_id"]);

      print("Enrolled in course: ${course["name"]}");
    } else {
      print("Failed to enroll in course: ${course["name"]}");
    }
  }
}
