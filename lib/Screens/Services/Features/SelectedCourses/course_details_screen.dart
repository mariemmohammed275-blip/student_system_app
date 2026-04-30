import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Controllers/assignment_controller.dart';
import 'package:student_systemv1/Controllers/slides_controller.dart';
import 'package:student_systemv1/Screens/Services/Features/SelectedCourses/assignment_details_screen.dart';
import 'package:student_systemv1/models/assignment.dart';
import 'package:student_systemv1/models/course_material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;

  CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  final SlidesController slidesController = Get.put(SlidesController());
  final AssignmentsController assignmentsController = Get.put(
    AssignmentsController(),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    slidesController.fetchSlides(courseId);
    assignmentsController.fetchAssignments(courseId);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xffF5F7FB),
        body: SafeArea(
          child: Column(
            children: [
              _CourseHeader(courseName: courseName),
              const _CourseTabs(),
              Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(
                      courseName: courseName,
                      slidesController: slidesController,
                      assignmentsController: assignmentsController,
                    ),
                    _MaterialsTab(
                      controller: slidesController,
                      mode: _MaterialMode.lectures,
                    ),
                    _AssignmentsTab(controller: assignmentsController),
                    _MaterialsTab(
                      controller: slidesController,
                      mode: _MaterialMode.sheets,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.courseName});

  final String courseName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: isDark ? Colors.white : Colors.black,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
                color: isDark ? Colors.white : Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A73FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(36),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Course workspace",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTabs extends StatelessWidget {
  const _CourseTabs();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        indicator: BoxDecoration(
          color: const Color(0xFF2A73FF),
          borderRadius: BorderRadius.circular(14),
        ),
        tabs: const [
          Tab(text: "Overview"),
          Tab(text: "Lectures"),
          Tab(text: "Assignments"),
          Tab(text: "Sheets"),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.courseName,
    required this.slidesController,
    required this.assignmentsController,
  });

  final String courseName;
  final SlidesController slidesController;
  final AssignmentsController assignmentsController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final materials = slidesController.slides;
      final assignments = assignmentsController.assignments;
      final sheets = materials.where(_isSheet).length;
      final lectures = materials.length - sheets;

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Row(
            children: [
              _OverviewStat(
                label: "Lectures",
                value: lectures.toString(),
                icon: Icons.play_lesson,
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              _OverviewStat(
                label: "Assignments",
                value: assignments.length.toString(),
                icon: Icons.assignment,
                color: Colors.orange,
              ),
              const SizedBox(width: 10),
              _OverviewStat(
                label: "Sheets",
                value: sheets.toString(),
                icon: Icons.description,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: "Progress"),
          const SizedBox(height: 10),
          _ProgressCard(courseName: courseName),
          const SizedBox(height: 18),
          _SectionTitle(title: "Recently Added"),
          const SizedBox(height: 10),
          if (materials.isEmpty && assignments.isEmpty)
            const _EmptyState(
              icon: Icons.folder_open,
              title: "No content yet",
              message: "Lectures, sheets, and assignments will appear here.",
            )
          else ...[
            ...materials.take(2).map(
                  (material) => _RecentItem(
                    title: material.title,
                    subtitle: "Lecture material",
                    icon: Icons.picture_as_pdf,
                    color: Colors.redAccent,
                    onTap: () => _openUrl(material.fullFileUrl),
                  ),
                ),
            ...assignments.take(2).map(
                  (assignment) => _RecentItem(
                    title: assignment.title,
                    subtitle: "Due ${assignment.formattedDeadline}",
                    icon: Icons.assignment_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Get.to(
                        () => AssignmentDetailsScreen(assignment: assignment),
                      );
                    },
                  ),
                ),
          ],
        ],
      );
    });
  }
}

class _MaterialsTab extends StatelessWidget {
  const _MaterialsTab({required this.controller, required this.mode});

  final SlidesController controller;
  final _MaterialMode mode;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = mode == _MaterialMode.sheets
          ? controller.slides.where(_isSheet).toList()
          : controller.slides.where((item) => !_isSheet(item)).toList();

      if (items.isEmpty) {
        return _EmptyState(
          icon: mode == _MaterialMode.sheets
              ? Icons.description_outlined
              : Icons.play_lesson_outlined,
          title: mode == _MaterialMode.sheets
              ? "No sheets yet"
              : "No lectures yet",
          message: mode == _MaterialMode.sheets
              ? "Uploaded sheets and lab files will appear here."
              : "Uploaded lecture materials will appear here.",
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final material = items[index];
          return _MaterialCard(
            material: material,
            index: index,
            mode: mode,
          );
        },
      );
    });
  }
}

class _AssignmentsTab extends StatelessWidget {
  const _AssignmentsTab({required this.controller});

  final AssignmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.assignments.isEmpty) {
        return const _EmptyState(
          icon: Icons.assignment_outlined,
          title: "No assignments yet",
          message: "New coursework and deadlines will appear here.",
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: controller.assignments.length,
        itemBuilder: (context, index) {
          final assignment = controller.assignments[index];
          return _AssignmentCard(assignment: assignment);
        },
      );
    });
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.courseName});

  final String courseName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF2A73FF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const Text(
                "68%",
                style: TextStyle(
                  color: Color(0xFF2A73FF),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.68,
              minHeight: 9,
              color: Color(0xFF2A73FF),
              backgroundColor: Color(0xffE9EEF5),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Keep following lectures and submit assignments before deadlines.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.material,
    required this.index,
    required this.mode,
  });

  final CourseMaterial material;
  final int index;
  final _MaterialMode mode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = mode == _MaterialMode.sheets ? Colors.green : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              mode == _MaterialMode.sheets
                  ? Icons.description
                  : Icons.picture_as_pdf,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  mode == _MaterialMode.sheets
                      ? "Sheet ${index + 1} - Dr. ${material.professorName}"
                      : "Lecture ${index + 1} - Dr. ${material.professorName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openUrl(material.fullFileUrl),
            icon: const Icon(Icons.download_rounded),
            color: const Color(0xFF2A73FF),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.to(() => AssignmentDetailsScreen(assignment: assignment)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.assignment, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Due ${assignment.formattedDeadline}",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              assignment.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  const _RecentItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum _MaterialMode { lectures, sheets }

bool _isSheet(CourseMaterial material) {
  final title = material.title.toLowerCase();
  return title.contains("sheet") ||
      title.contains("section") ||
      title.contains("lab");
}

Future<void> _openUrl(String url) async {
  if (url.isEmpty) {
    Get.snackbar("Error", "No file attached to this document");
    return;
  }

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    Get.snackbar("Error", "Could not open this file");
  }
}
