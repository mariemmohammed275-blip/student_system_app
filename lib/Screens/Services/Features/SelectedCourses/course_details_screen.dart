import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/assignment_controller.dart';
import 'package:student_systemv1/Screens/Services/Features/SelectedCourses/assignment_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Controllers/slides_controller.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            courseName,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          bottom: TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(icon: Icon(Icons.picture_as_pdf), text: "Materials"),
              Tab(icon: Icon(Icons.assignment), text: "Assignments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CourseMaterialsView(courseId: courseId),
            CourseAssignmentsView(courseId: courseId),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// --- TAB 1: MATERIALS (PDFs) ---
// ==========================================
class CourseMaterialsView extends StatelessWidget {
  final String courseId;
  CourseMaterialsView({super.key, required this.courseId});

  final SlidesController controller = Get.put(SlidesController());

  @override
  Widget build(BuildContext context) {
    // Safe to call here because of the Controller Guard!
    controller.fetchSlides(courseId);

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.slides.isEmpty) {
        return Center(
          child: Text(
            "No materials available yet.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.slides.length,
        itemBuilder: (context, index) {
          // This is now a strongly-typed CourseMaterial object!
          final material = controller.slides[index];

          return Card(
            color: isDark ? Colors.grey[800] : Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red[900]?.withOpacity(0.3)
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.redAccent,
                ),
              ),

              // Super clean properties!
              title: Text(
                material.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                "Dr. ${material.professorName}",
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: Icon(
                Icons.download_rounded,
                color: isDark ? Colors.blueAccent : Colors.blue,
              ),

              onTap: () async {
                // Using our helper URL from the Model!
                if (material.fullFileUrl.isNotEmpty) {
                  final uri = Uri.parse(material.fullFileUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } else {
                  Get.snackbar("Error", "No file attached to this document");
                }
              },
            ),
          );
        },
      );
    });
  }
}

// ==========================================
// --- TAB 2: ASSIGNMENTS ---
// ==========================================

class CourseAssignmentsView extends StatelessWidget {
  final String courseId;
  CourseAssignmentsView({super.key, required this.courseId});

  final AssignmentsController controller = Get.put(AssignmentsController());

  @override
  Widget build(BuildContext context) {
    controller.fetchAssignments(courseId);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.assignments.isEmpty) {
        return Center(
          child: Text(
            "No assignments available.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.assignments.length,
        itemBuilder: (context, index) {
          // THIS IS THE FIX 👇
          // We define the specific assignment for this row here
          final assignment = controller.assignments[index];

          return Card(
            color: isDark ? Colors.grey[800] : Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.orange[900]?.withOpacity(0.3)
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pending_actions, color: Colors.orange),
              ),
              title: Text(
                assignment.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    assignment.description,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Due: ${assignment.formattedDeadline}",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey,
              ),

              // Now the onTap can see the 'assignment' variable!
              onTap: () {
                Get.to(() => AssignmentDetailsScreen(assignment: assignment));
              },
            ),
          );
        },
      );
    });
  }
}
