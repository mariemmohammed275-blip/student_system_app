import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/config/api_config.dart';
import '../Controllers/auth_controller.dart';

class DioClient {
  static Dio getDio() {
    final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final auth = Get.find<AuthController>();
          final token = auth.token.value;

          if (token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}
