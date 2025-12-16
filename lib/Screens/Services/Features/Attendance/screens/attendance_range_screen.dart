import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/API/attendance_api.dart';

class AttendanceRangeScreen extends StatefulWidget {
  @override
  _AttendanceRangeScreenState createState() => _AttendanceRangeScreenState();
}

class _AttendanceRangeScreenState extends State<AttendanceRangeScreen> {
  String from = "";
  String to = "";
  List data = [];
  bool loading = false;

  Future<void> load(String courseId) async {
    setState(() => loading = true);

    final res = await AttendanceAPI.getRange(courseId, from, to);

    setState(() {
      data = res["data"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseId = Get.arguments;

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Range")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(label: Text("From (YYYY-MM-DD)")),
              onChanged: (v) => from = v,
            ),
            TextField(
              decoration: InputDecoration(label: Text("To (YYYY-MM-DD)")),
              onChanged: (v) => to = v,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => load(courseId),
              child: Text("Search"),
            ),
            SizedBox(height: 20),

            loading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        final d = data[i];
                        return ListTile(
                          title: Text(d["date"]),
                          subtitle: Text("Status: ${d["status"]}"),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
