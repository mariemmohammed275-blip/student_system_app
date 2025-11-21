// File: services/api_service.dart
import 'package:dio/dio.dart';
import '../models/student.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.3:5000/api';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // -----------------------------
  // SIGN UP API
  // -----------------------------
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/students/signup',
        data: {
          "full_name": fullName,
          "email": email,
          "password": password,
          "confirm_password": confirmPassword,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioError catch (e) {
      if (e.response != null) {
        return e.response!.data as Map<String, dynamic>;
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // -----------------------------
  // LOGIN API
  // -----------------------------
  static Future<Student?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/students/login',
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200 && response.data != null) {
        return Student.fromJson(response.data);
      } else {
        return null; // Login failed
      }
    } on DioError catch (e) {
      throw Exception(
        'Network or server error: ${e.response?.data ?? e.message}',
      );
    }
  }
}
