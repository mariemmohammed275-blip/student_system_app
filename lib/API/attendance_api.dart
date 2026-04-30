import 'package:dio/dio.dart';

class AttendanceAPI {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.8:5000/api/attendance/me",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  static String token = ""; // حطي التوكن هنا بعد اللوجين

  static Options get headers =>
      Options(headers: {"Authorization": "Bearer $token"});

  // GET summary
  static Future<List<dynamic>> getSummary() async {
    final response = await dio.get("/summary", options: headers);
    return response.data["courses"];
  }

  // POST full course history
  static Future<Map<String, dynamic>> getCourseHistory(String courseId) async {
    final response = await dio.post(
      "/course",
      data: {"courseId": courseId},
      options: headers,
    );
    return response.data;
  }

  // POST range
  static Future<Map<String, dynamic>> getRange(
    String courseId,
    String from,
    String to,
  ) async {
    final response = await dio.post(
      "/range",
      data: {"courseId": courseId, "from": from, "to": to},
      options: headers,
    );
    return response.data;
  }
}
