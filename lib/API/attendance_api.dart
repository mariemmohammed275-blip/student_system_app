import 'package:dio/dio.dart';
import 'package:student_systemv1/API/api_service.dart';

class AttendanceAPI {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "${ApiService.baseUrl}/attendance",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static String token = "";

  static Options get headers {
    final activeToken = token.isNotEmpty ? token : ApiService.token;

    return Options(
      headers: activeToken == null || activeToken.isEmpty
          ? null
          : {"Authorization": "Bearer $activeToken"},
    );
  }

  static Future<List<dynamic>> getSummary() async {
    final response = await dio.get("/me/summary", options: headers);
    return response.data["courses"] ?? [];
  }

  static Future<Map<String, dynamic>> getCourseHistory(String courseId) async {
    final response = await dio.post(
      "/me/course",
      data: {"courseId": courseId},
      options: headers,
    );
    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> getRange(
    String courseId,
    String from,
    String to,
  ) async {
    final response = await dio.post(
      "/me/range",
      data: {"courseId": courseId, "from": from, "to": to},
      options: headers,
    );
    return Map<String, dynamic>.from(response.data);
  }

  static Future<List<dynamic>> getWarnings() async {
    final response = await dio.get("/me/warnings", options: headers);
    return response.data["warnings"] ?? [];
  }

  static Future<Map<String, dynamic>> scanLectureQr(String qrToken) async {
    try {
      final response = await dio.post(
        "/lecture-session/scan",
        data: {"qrToken": qrToken},
        options: headers,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return {
        "success": false,
        "message": "Unable to scan attendance right now.",
      };
    }
  }
}
