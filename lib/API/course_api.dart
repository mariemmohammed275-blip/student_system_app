import 'package:dio/dio.dart';

class CourseAPI {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.20.1:5000/api",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  static String token = "";

  // GET all courses
  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final response = await dio.get(
        "/courses/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        // Handle various backend structures safely
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        }

        if (response.data["courses"] != null) {
          return List<Map<String, dynamic>>.from(response.data["courses"]);
        }

        if (response.data["data"] != null) {
          return List<Map<String, dynamic>>.from(response.data["data"]);
        }
      }

      return [];
    } catch (e) {
      print("Failed to load courses: $e");
      return [];
    }
  }

  // POST enroll in a course
  static Map<String, dynamic>? lastEnrolledStudent; // store last student object

  static Future<bool> enrollCourse({
    required String studentId,
    required String courseId,
  }) async {
    try {
      final response = await dio.post(
        "/students/enroll",
        data: {"courseId": courseId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        lastEnrolledStudent = response.data["data"];
        return true;
      } else {
        print("Enroll failed: ${response.data["message"]}");
        return false;
      }
    } catch (e) {
      print("Enroll error: $e");
      return false;
    }
  }
}
