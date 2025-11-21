import 'package:dio/dio.dart';
import 'package:student_systemv1/models/student.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.3:5000/api/students",
      // this is my ip address, don't forget to change it to your own ip
      headers: {"Content-Type": "application/json"},
    ),
  );

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
      final response = await _dio.post(
        "/signup",
        data: {
          "full_name": fullName,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Student.fromJson(response.data["student"]);
      } else {
        print("Sign Up failed: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Sign Up error: $e");
      return null;
    }
  }

  // Login
  Future<Student?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return Student.fromJson(response.data["student"]);
      } else {
        print("Login failed: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}
