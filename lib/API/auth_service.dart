import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/auth_controller.dart';
import 'package:student_systemv1/API/attendance_api.dart';
import 'package:student_systemv1/API/course_api.dart';
import 'package:student_systemv1/models/student.dart';
import 'api_service.dart';

class AuthService {
  static Student? currentStudent;

  Future<Student?> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService.signup(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response.containsKey('student')) {
        final student = Student.fromJson(response['student']);
        return student;
      } else {
        print('Sign Up failed: ${response['message']}');
        return null;
      }
    } catch (e) {
      print('Sign Up error: $e');
      return null;
    }
  }

  Future<Student?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.loginRaw(
        email: email,
        password: password,
      );

      if (response == null) {
        print("Login failed");
        return null;
      }

      final String token = response["token"];
      ApiService.token = token;
      CourseAPI.token = token;
      AttendanceAPI.token = token;
      ApiService.setToken(token);

      // ----------------------------------------------------
      // THIS IS THE FIX: Save the token to AuthController!
      // ----------------------------------------------------
      Get.find<AuthController>().saveToken(token);

      print("Token saved successfully.");

      final meResponse = await ApiService.getMe();

      if (meResponse == null) {
        print("Failed to load student profile.");
        return null;
      }

      final student = Student.fromJson(meResponse);
      currentStudent = student;

      print("Student loaded successfully: ${student.fullName}");

      return student;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  void logout() {
    currentStudent = null;
    ApiService.token = null;
    AttendanceAPI.token = "";
    CourseAPI.token = "";
    ApiService.clearToken();

    // Clear token from GetX state manager too
    Get.find<AuthController>().logout();

    print("Logged out successfully.");
  }
}
