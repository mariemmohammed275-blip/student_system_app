import 'package:dio/dio.dart';

class CourseAPI {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.5:5000/api",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  static String token = "";

  // GET student courses
  static Future<List<Map<String, dynamic>>> getAllCourses() async {
    try {
      final response = await dio.get(
        "/students/courses",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data["courses"]);
      }

      return [];
    } catch (e) {
      throw Exception("Failed to load courses: $e");
    }
  }

  // POST enroll in a course
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

      if (response.statusCode == 200 &&
          response.data["message"] == "Course enrolled successfully") {
        return true;
      }

      return false;
    } catch (e) {
      print("Enroll error: $e");
      return false;
    }
  }
}
