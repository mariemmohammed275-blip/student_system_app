import 'package:dio/dio.dart';
import 'package:student_systemv1/config/api_config.dart';
import 'package:student_systemv1/models/notification.dart';
import 'package:student_systemv1/models/timetable_item.dart';
import '../models/event.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 50),
      receiveTimeout: const Duration(seconds: 50),
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

  // -----------------------------
  // EVENTS API
  // -----------------------------
  static Future<List<FacultyEvent>> getEvents() async {
    try {
      final response = await _dio.get('/students/events');

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => FacultyEvent.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print("getEvents error: $e");
      return [];
    }
  }

  // -----------------------------
  // NOTIFICATIONS API
  // -----------------------------
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      // Changed from _dio.get to _dio.post 👇
      final response = await _dio.post('/notifications/list');

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print("getNotifications error: $e");
      return [];
    }
  }

  // -----------------------------
  // COURSE ANNOUNCEMENTS API
  // -----------------------------
  static Future<List<NotificationModel>> getCourseAnnouncements() async {
    try {
      final response = await _dio.get('/announcements/student');

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        // Reusing the NotificationModel since we updated it to handle 'content'
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print("getCourseAnnouncements error: $e");
      return [];
    }
  }

  // -----------------------------
  // TIMETABLE API
  // -----------------------------
  static Future<List<TimetableItem>> getTimetable() async {
    try {
      final response = await _dio.get('/students/timetable');

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => TimetableItem.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print("getTimetable error: $e");
      return [];
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
