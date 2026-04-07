import 'package:get/get.dart';
import 'package:student_systemv1/API/course_api.dart';

class SlidesController extends GetxController {
  var slides = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  Future<void> fetchSlides(String courseId) async {
    isLoading.value = true;

    final data = await CourseAPI.getCourseSlides(courseId);
    slides.assignAll(data);

    isLoading.value = false;
  }
}
