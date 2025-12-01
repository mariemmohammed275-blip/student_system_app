class Student {
  final String id;
  final String studentId;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String dob;
  final String address;
  final String enrollmentStatus;
  final String departmentName;
  final int coursesCount;
  final List<String> courses; // List of enrolled course IDs

  Student({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.address,
    required this.enrollmentStatus,
    required this.departmentName,
    required this.coursesCount,
    required this.courses,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    // Safely parse courses
    List<String> courseIds = [];
    if (json["courses"] != null) {
      courseIds = List<String>.from(
        json["courses"].map((c) {
          if (c is Map && c.containsKey("_id")) {
            return c["_id"].toString();
          } else {
            return c.toString();
          }
        }),
      );
    }

    return Student(
      id: json["_id"] ?? "",
      studentId: json["student_id"] ?? "",
      fullName: json["full_name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      gender: json["gender"] ?? "",
      dob: json["dob"] ?? "",
      address: json["address"] ?? "",
      enrollmentStatus: json["enrollment_status"] ?? "",
      departmentName: json["department_id"]?["dept_name"] ?? "",
      coursesCount: courseIds.length,
      courses: courseIds,
    );
  }
}
