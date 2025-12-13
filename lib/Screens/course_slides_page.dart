import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controllers/slides_controller.dart';

class CourseSlidesPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  CourseSlidesPage({required this.courseId, required this.courseName});

  final SlidesController controller = Get.put(SlidesController());

  @override
  Widget build(BuildContext context) {
    controller.fetchSlides(courseId);

    return Scaffold(
      appBar: AppBar(title: Text(courseName), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.slides.isEmpty) {
          return Center(child: Text("No slides available"));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.slides.length,
          itemBuilder: (context, index) {
            final slide = controller.slides[index];
            final fullUrl = "http://192.168.1.7:5000${slide["fileUrl"]}";

            return Card(
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(slide["title"]),
                subtitle: Text("Dr. ${slide["professor"]["name"]}"),
                trailing: Icon(Icons.open_in_new),
                onTap: () async {
                  final uri = Uri.parse(fullUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }
}
