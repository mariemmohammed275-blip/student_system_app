import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/grades_controller.dart';

class Grades extends StatelessWidget {
  final GradesController controller = Get.put(GradesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Grades"),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final data = controller.gradeResponse.value;

        if (data == null || data.data.isEmpty) {
          return Center(child: Text("No Grades Found"));
        }

        final gradeList = data.data;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: gradeList.length,
            itemBuilder: (context, index) {
              final courseItem = gradeList[index];

              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${courseItem.course.name} (${courseItem.course.code})",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      if (courseItem.grades.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "No grades yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...courseItem.grades.map(
                          (g) => ListTile(
                            title: Text("Grade: ${g.grade}"),
                            subtitle: Text(
                              "Dr ID: ${g.professorId}",
                            ), // تعديل هنا
                            trailing: Icon(Icons.school),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
