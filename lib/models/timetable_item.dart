class TimetableItem {
  final String id;
  final String courseName;
  final String courseCode;
  final String instructor;
  final String room;
  final String day;
  final String startTime;
  final String endTime;

  TimetableItem({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.instructor,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory TimetableItem.fromJson(Map<String, dynamic> json) {
    return TimetableItem(
      id: json['id'] ?? '',
      courseName: json['course_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      instructor: json['instructor'] ?? '',
      room: json['room'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}
