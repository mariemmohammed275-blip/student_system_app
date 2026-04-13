import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Screens/Services/Features/SelectedCourses/course_details_screen.dart';
import '../CourseEnrollment/course_controller.dart';

// 1. Changed to a StatefulWidget
class SelectedCourses extends StatefulWidget {
  const SelectedCourses({super.key});

  @override
  State<SelectedCourses> createState() => _SelectedCoursesState();
}

class _SelectedCoursesState extends State<SelectedCourses> {
  final CourseController controller = Get.find();

  // 2. Added initState to fetch courses when the screen opens!
  @override
  void initState() {
    super.initState();
    // Only fetch if the list is completely empty so we don't waste data
    if (controller.allCourses.isEmpty) {
      controller.fetchCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Selected Courses",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Obx(() {
        // 3. Show a loading spinner if the courses are currently downloading
        if (controller.allCourses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.selectedCourses.isEmpty) {
          return Center(
            child: Text(
              "No courses selected yet.",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.selectedCourses.length,
          itemBuilder: (context, index) {
            final course = controller.selectedCourses[index];

            return Card(
              color: isDark ? Colors.grey[800] : Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.blue[900]?.withOpacity(0.3)
                        : Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.book,
                    color: isDark ? Colors.blueAccent : Colors.blue,
                  ),
                ),
                title: Text(
                  course["name"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  course["code"],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
                onTap: () {
                  Get.to(
                    () => CourseDetailsScreen(
                      courseId: course["_id"],
                      courseName: course["name"],
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
