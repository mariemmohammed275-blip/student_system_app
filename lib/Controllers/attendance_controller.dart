import 'package:get/get.dart';
import '../API/attendance_api.dart';
import '../Screens/Services/Features/Attendance/model/attendance_summary.dart';

class AttendanceController extends GetxController {
  var courses = <AttendanceCourseSummary>[].obs;
  var warnings = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  Future<void> loadSummary() async {
    loading.value = true;
    errorMessage.value = '';

    try {
      final data = await AttendanceAPI.getSummary();
      courses.value = data
          .map((e) => AttendanceCourseSummary.fromJson(e))
          .toList();

      final warningData = await AttendanceAPI.getWarnings();
      warnings.value = warningData
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      errorMessage.value = 'Unable to load attendance right now.';
    } finally {
      loading.value = false;
    }
  }
}
