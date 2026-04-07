import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Screens/course_slides_page.dart';
import '../CourseEnrollment/course_controller.dart';

class SelectedCourses extends StatelessWidget {
  final CourseController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selected Courses"), centerTitle: true),
      body: Obx(() {
        if (controller.selectedCourses.isEmpty) {
          return Center(child: Text("No courses selected yet."));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.selectedCourses.length,
          itemBuilder: (context, index) {
            final course = controller.selectedCourses[index];

            return Card(
              child: ListTile(
                title: Text(course["name"]),
                subtitle: Text(course["code"]),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.to(
                    () => CourseSlidesPage(
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
