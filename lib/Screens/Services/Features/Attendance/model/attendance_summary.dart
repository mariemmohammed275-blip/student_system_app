class AttendanceCourseSummary {
  final String courseId;
  final String courseName;
  final int present;
  final int absent;
  final int totalLectures;
  final double percentage;

  AttendanceCourseSummary({
    required this.courseId,
    required this.courseName,
    required this.present,
    required this.absent,
    required this.totalLectures,
    required this.percentage,
  });

  factory AttendanceCourseSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceCourseSummary(
      courseId: json["courseId"],
      courseName: json["courseName"],
      present: json["present"],
      absent: json["absent"],
      totalLectures: json["totalLectures"],
      percentage: double.tryParse(json["percentage"].toString()) ?? 0,
    );
  }
}
