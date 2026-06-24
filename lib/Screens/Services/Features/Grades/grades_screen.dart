import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:student_systemv1/Controllers/grades_controller.dart';

class Grades extends StatelessWidget {
  final GradesController controller = Get.put(GradesController());

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Applying the same professional background color from the Payments screen
    final Color scaffoldColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          "My Grades",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: isDark ? Colors.redAccent : Colors.red,
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: isDark ? Colors.redAccent : Colors.red,
                    fontSize: 16,
                  ),
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
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  "No grades published yet.",
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final courseList = data.data;

        return RefreshIndicator(
          onRefresh: controller.fetchGrades,
          color: Colors.blueAccent,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            itemCount: courseList.length,
            itemBuilder: (context, index) {
              final courseItem = courseList[index];

              return _buildGradeCard(courseItem, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _buildGradeCard(courseItem, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: Course Info ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blueAccent.withOpacity(0.15)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: isDark ? Colors.blue[300] : Colors.blueAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseItem.course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseItem.course.code,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: isDark ? Colors.white10 : Colors.grey[100],
              height: 1,
            ),
          ),

          // --- BODY: Grades List ---
          if (courseItem.grades.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No grades added yet.",
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...courseItem.grades.map((gradeInfo) {
              bool isPass = gradeInfo.grade >= 50;

              // Format date cleanly using Intl package
              String formattedDate = "Recently";
              if (gradeInfo.createdAt != null) {
                try {
                  DateTime parsedDate = DateTime.parse(
                    gradeInfo.createdAt.toString(),
                  );
                  formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);
                } catch (e) {
                  formattedDate = gradeInfo.createdAt!.toString().substring(
                    0,
                    10,
                  );
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date Posted",
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),

                    // Right Side: Score & Badge
                    Row(
                      children: [
                        Text(
                          "${gradeInfo.grade.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isPass
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.red[300] : Colors.red[700]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(isPass, isDark),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // --- Matching Pass/Fail Badge ---
  Widget _buildStatusBadge(bool isPass, bool isDark) {
    final bgColor = isPass
        ? (isDark ? Colors.green.withOpacity(0.15) : Colors.green[50])
        : (isDark ? Colors.red.withOpacity(0.15) : Colors.red[50]);

    final textColor = isPass
        ? (isDark ? Colors.greenAccent : Colors.green[700])
        : (isDark ? Colors.redAccent : Colors.red[700]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor!.withOpacity(0.2), width: 1),
      ),
      child: Text(
        isPass ? "PASS" : "FAIL",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
