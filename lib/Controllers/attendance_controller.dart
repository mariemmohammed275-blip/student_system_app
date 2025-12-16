import 'package:get/get.dart';
import '../API/attendance_api.dart';
import '../Screens/Services/Features/Attendance/model/attendance_summary.dart';

class AttendanceController extends GetxController {
  var courses = <AttendanceCourseSummary>[].obs;
  var loading = false.obs;

  Future<void> loadSummary() async {
    loading.value = true;

    try {
      final data = await AttendanceAPI.getSummary();
      courses.value = data
          .map((e) => AttendanceCourseSummary.fromJson(e))
          .toList();
    } catch (e) {
      print(e);
    } finally {
      loading.value = false;
    }
  }
}
