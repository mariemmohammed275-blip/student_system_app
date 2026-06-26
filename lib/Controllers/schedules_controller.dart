import 'package:get/get.dart';
import 'package:student_systemv1/models/timetable_item.dart';
import 'package:student_systemv1/API/api_service.dart';

class SchedulesController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Reactive variables for the UI
  var groupedSchedule = <String, List<TimetableItem>>{}.obs;
  var sortedDays = <String>[].obs;

  // Custom ordering so days appear chronologically
  final Map<String, int> _dayOrder = const {
    "Saturday": 1,
    "Sunday": 2,
    "Monday": 3,
    "Tuesday": 4,
    "Wednesday": 5,
    "Thursday": 6,
    "Friday": 7,
  };

  @override
  void onInit() {
    super.onInit();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    try {
      isLoading(true);
      errorMessage('');

      var data = await ApiService.getTimetable();

      if (data.isEmpty) {
        groupedSchedule.clear();
        sortedDays.clear();
        return;
      }

      // 1. Group classes by their day
      Map<String, List<TimetableItem>> tempGrouped = {};
      for (var item in data) {
        if (!tempGrouped.containsKey(item.day)) {
          tempGrouped[item.day] = [];
        }
        tempGrouped[item.day]!.add(item);
      }

      // 2. Sort the days chronologically
      List<String> tempSortedDays = tempGrouped.keys.toList()
        ..sort((a, b) => (_dayOrder[a] ?? 8).compareTo(_dayOrder[b] ?? 8));

      // 3. Sort classes within each day by start time
      for (var day in tempSortedDays) {
        tempGrouped[day]!.sort((a, b) => a.startTime.compareTo(b.startTime));
      }

      // Update the reactive variables
      groupedSchedule.value = tempGrouped;
      sortedDays.value = tempSortedDays;
    } catch (e) {
      errorMessage('Error loading schedule.');
      print("Schedule Controller Error: $e");
    } finally {
      isLoading(false);
    }
  }
}
