import 'package:dio/dio.dart';
import 'package:student_systemv1/config/api_config.dart';

class CourseAPI {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
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

  // GET slides for a specific course
  static Future<List<Map<String, dynamic>>> getCourseSlides(
    String courseId,
  ) async {
    try {
      final response = await dio.post(
        "/slides/list",
        data: {"courseId": courseId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return List<Map<String, dynamic>>.from(response.data["data"]);
      }

      return [];
    } catch (e) {
      print("Failed to load slides: $e");
      return [];
    }
  }

  // GET assignments for a specific course
  static Future<List<Map<String, dynamic>>> getCourseAssignments(
    String courseId,
  ) async {
    try {
      final response = await dio.post(
        "/assignments/list",
        data: {"courseId": courseId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return List<Map<String, dynamic>>.from(response.data["data"]);
      }

      return [];
    } catch (e) {
      print("Failed to load assignments: $e");
      return [];
    }
  }

  // POST: Upload student assignment
  static Future<bool> submitAssignment({
    required String assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      // 1. Package the data exactly how your backend expects it
      FormData formData = FormData.fromMap({
        "assignmentId": assignmentId,
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      // 2. Send the request (Passing the ID in the query param AND body as requested)
      final response = await dio.post(
        "/assignments/submit?assignmentId=$assignmentId",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      // 3. Return true if successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("Upload failed: $e");
      return false;
    }
  }
}
