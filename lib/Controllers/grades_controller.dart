import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/API/dio_client.dart';
import 'package:student_systemv1/models/grade.dart';

class GradesController extends GetxController {
  // Variables to track the screen state
  var isLoading = true.obs;
  var gradeResponse = Rxn<GradeResponse>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGrades(); // Call the API when the controller starts
  }

  Future<void> fetchGrades() async {
    try {
      isLoading(true);
      errorMessage('');

      final dio = DioClient.getDio();
      final response = await dio.get("/students/grades");

      if (response.statusCode == 200) {
        gradeResponse.value = GradeResponse.fromJson(response.data);
      } else {
        errorMessage("Unexpected status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        errorMessage("Server Error: ${e.response?.statusCode}");
      } else {
        // This will print the EXACT reason it failed to connect
        print("Error Type: ${e.type}");
        print("Real Error: ${e.error}");
        errorMessage("Network Error. Check the console.");
      }
    } catch (e) {
      errorMessage("An unknown error occurred");
      print("Unknown Error: $e");
    } finally {
      isLoading(false);
    }
  }
}
