// File: lib/Screens/Services/Features/Grades/grades_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/grades_controller.dart';

class Grades extends StatelessWidget {
  final GradesController controller = Get.put(GradesController());

  @override
  Widget build(BuildContext context) {
    // 1. Detect if the app is in dark mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Match the background to the theme automatically
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          "My Grades",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Matches SelectedCourses
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final data = controller.gradeResponse.value;

        if (data == null || data.data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  "No grades published yet.",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        final courseList = data.data;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: courseList.length,
          itemBuilder: (context, index) {
            final courseItem = courseList[index];

            return Card(
              // 2. Adjust card color for Dark/Light mode
              color: isDark ? Colors.grey[800] : Colors.white,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ), // Same shape as SelectedCourses
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER (Matches Selected Courses List Tile) ---
                    Row(
                      children: [
                        // The circular icon background
                        Container(
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
                        const SizedBox(width: 12),
                        // Course Name and Code
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courseItem.course.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                courseItem.course.code,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Divider(
                      height: 24,
                      thickness: 1,
                      color: isDark ? Colors.grey[700] : Colors.grey[200],
                    ),

                    // --- BODY (GRADES LIST) ---
                    if (courseItem.grades.isEmpty)
                      Text(
                        "No grades added yet.",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      )
                    else
                      ...courseItem.grades.map((gradeInfo) {
                        bool isPass = gradeInfo.grade >= 50;

                        String dateText = "Recent";
                        if (gradeInfo.createdAt != null) {
                          dateText = gradeInfo.createdAt!.toString().substring(
                            0,
                            10,
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date Posted",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${gradeInfo.grade}%",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      // Soften colors slightly in dark mode
                                      color: isPass
                                          ? (isDark
                                                ? Colors.greenAccent
                                                : Colors.green[700])
                                          : (isDark
                                                ? Colors.redAccent
                                                : Colors.red[700]),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPass
                                          ? Colors.green.withOpacity(
                                              isDark ? 0.2 : 0.1,
                                            )
                                          : Colors.red.withOpacity(
                                              isDark ? 0.2 : 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isPass ? "Pass" : "Fail",
                                      style: TextStyle(
                                        color: isPass
                                            ? (isDark
                                                  ? Colors.greenAccent
                                                  : Colors.green[700])
                                            : (isDark
                                                  ? Colors.redAccent
                                                  : Colors.red[700]),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
