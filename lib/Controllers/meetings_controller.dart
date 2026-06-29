import 'package:get/get.dart';
import '../API/api_service.dart';
import '../models/notification.dart';

class MeetingsController extends GetxController {
  var meetings = <NotificationModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch data immediately when the screen opens
    fetchMeetings();
  }

  void fetchMeetings() async {
    try {
      isLoading(true);
      // Fetch all course announcements
      final data = await ApiService.getCourseAnnouncements();

      // Filter the list to only include meetings
      meetings.assignAll(data.where((item) => item.type == 'meeting').toList());
    } catch (e) {
      print("Error fetching meetings: $e");
    } finally {
      isLoading(false);
    }
  }
}
