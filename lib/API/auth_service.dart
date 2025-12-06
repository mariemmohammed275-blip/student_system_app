import 'package:student_systemv1/API/course_api.dart';
import 'package:student_systemv1/models/student.dart';
import 'api_service.dart';

class AuthService {
  // ---------------------
  // Global logged-in student
  // ---------------------
  static Student? currentStudent;

  // ---------------------
  // Sign Up
  // ---------------------
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

  // ---------------------
  // LOGIN
  // ---------------------
  Future<Student?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: login
      final response = await ApiService.loginRaw(
        email: email,
        password: password,
      );

      if (response == null) {
        print("Login failed");
        return null;
      }

      final String token = response["token"];
      ApiService.token = token; // ← important
      // After fetching token
      CourseAPI.token = token; // <-- Add this line

      ApiService.setToken(token); // set to Dio headers

      print("Token saved successfully.");

      // Step 2: fetch student data from /me
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

  // ---------------------
  // LOGOUT
  // ---------------------
  void logout() {
    currentStudent = null;
    ApiService.token = null;
    ApiService.clearToken();
    print("Logged out successfully.");
  }
}
