import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:5000/api';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static String? token;

  static void setToken(String newToken) {
    token = newToken;
    _dio.options.headers["Authorization"] = "Bearer $newToken";
  }

  static void clearToken() {
    token = null;
    _dio.options.headers.remove("Authorization");
  }

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
  static Future<Map<String, dynamic>?> loginRaw({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/students/login',
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioError catch (e) {
      print("Login error: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _dio.get("/students/me");

      if (response.statusCode == 200) {
        return response.data["data"];
      }

      return null;
    } catch (e) {
      print("getMe error: $e");
      return null;
    }
  }
}
