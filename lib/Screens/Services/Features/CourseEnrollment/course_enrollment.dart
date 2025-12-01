import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Screens/Services/Features/SelectedCourses/selected_courses.dart';
import 'course_controller.dart';

class CourseEnrollment extends StatefulWidget {
  @override
  State<CourseEnrollment> createState() => _CourseEnrollmentState();
}

class _CourseEnrollmentState extends State<CourseEnrollment> {
  final CourseController controller = Get.put(CourseController());

  @override
  void initState() {
    super.initState();
    controller.fetchCourses(); // fetch all courses and separate unenrolled
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Course Enrollment"), centerTitle: true),
      body: Obx(() {
        // Show loading while courses are fetched
        if (controller.allCourses.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // If there are no unenrolled courses
        if (controller.unenrolledCourses.isEmpty) {
          return Center(
            child: Text(
              "No courses available to enroll.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: controller.unenrolledCourses.length,
                  itemBuilder: (context, index) {
                    final course = controller.unenrolledCourses[index];
                    final bool added = controller.isAdded(course["_id"]);

                    return CourseBox(
                      name: course["name"],
                      code: course["code"],
                      isAdded: added,
                      onAdd: () async {
                        await controller.addCourse(course);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${course["name"]} added!")),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => SelectedCourses()),
                icon: Icon(Icons.list),
                label: Text("View Selected Courses"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CourseBox extends StatelessWidget {
  final String name;
  final String code;
  final bool isAdded;
  final VoidCallback onAdd;

  const CourseBox({
    Key? key,
    required this.name,
    required this.code,
    required this.isAdded,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAdded
              ? [Colors.grey.shade300, Colors.grey.shade400]
              : [Colors.lightBlueAccent, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(code, style: TextStyle(color: Colors.black54)),
          Spacer(),
          ElevatedButton(
            onPressed: isAdded ? null : onAdd,
            child: Text(isAdded ? "Added" : "Add"),
          ),
        ],
      ),
    );
  }
}
