import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              ),
            );
          },
        );
      }),
    );
  }
}
