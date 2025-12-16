import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/attendance_controller.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    controller.loadSummary();

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Summary")),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.courses.isEmpty) {
          return Center(child: Text("No attendance available."));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.courses.length,
          itemBuilder: (context, index) {
            final c = controller.courses[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.courseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    LinearProgressIndicator(
                      value: c.percentage / 100,
                      minHeight: 8,
                    ),
                    SizedBox(height: 8),
                    Text("Attendance: ${c.percentage}%"),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Present: ${c.present}"),
                        Text("Absent: ${c.absent}"),
                        Text("Total: ${c.totalLectures}"),
                      ],
                    ),

                    SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(
                          "/attendance-course-history",
                          arguments: c.courseId,
                        );
                      },
                      child: Text("View Full History"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
