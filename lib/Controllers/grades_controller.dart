import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Screens/Services/Features/Grades/grade_model.dart';

class GradesController extends GetxController {
  var isLoading = true.obs;
  var gradeResponse = Rxn<GradeResponse>();

  final dio = Dio(BaseOptions(baseUrl: "http://192.168.20.1:5000/api"));

  Future<void> fetchGrades() async {
    try {
      isLoading(true);

      final res = await dio.get(
        "/students/grades",
        options: Options(
          headers: {
            "Authorization":
                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MzFiY2RlZTVkODdhOGQ3YmNlMzQ1NyIsInJvbGUiOiJzdHVkZW50IiwiZW1haWwiOiJ0dXlpdWhqZ2tobmJodmtneUBnbWFpbC5jb20iLCJpYXQiOjE3NjUzODIzODYsImV4cCI6MTc2NTM4NTk4Nn0.l7_Z0I_Brbnr7B_nxdLul-xXNu7QqJkkK7EvUF0twBA",
          },
        ),
      );

      gradeResponse.value = GradeResponse.fromJson(res.data);
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    fetchGrades();
    super.onInit();
  }
}
