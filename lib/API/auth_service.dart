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
  // Login
  // ---------------------
  Future<Student?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Use loginRaw to get full response including token
      final response = await ApiService.loginRaw(
        email: email,
        password: password,
      );

      if (response == null) return null;

      // Extract student info
      final student = Student.fromJson(response["student"]);
      currentStudent = student;

      // Extract token and store it in CourseAPI
      CourseAPI.token = response["token"];
      print("Login successful. Token set for CourseAPI.");

      return student;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // ---------------------
  // Logout
  // ---------------------
  void logout() {
    currentStudent = null;
    CourseAPI.token = ""; // Clear token on logout
    print("User logged out and token cleared.");
  }
}
