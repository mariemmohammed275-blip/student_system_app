class GradeResponse {
  final bool success;
  final String message;
  final List<GradeCourse> data;

  GradeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GradeResponse.fromJson(Map<String, dynamic> json) {
    return GradeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: (json['data'] as List).map((e) => GradeCourse.fromJson(e)).toList(),
    );
  }
}

class GradeCourse {
  final Course course;
  final List<GradeItem> grades;

  GradeCourse({required this.course, required this.grades});

  factory GradeCourse.fromJson(Map<String, dynamic> json) {
    return GradeCourse(
      course: Course.fromJson(json['course']),
      grades: (json['grades'] as List)
          .map((e) => GradeItem.fromJson(e))
          .toList(),
    );
  }
}

class Course {
  final String name;
  final String code;

  Course({required this.name, required this.code});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(name: json['name'] ?? "", code: json['code'] ?? "");
  }
}

class GradeItem {
  final int grade;
  final String professorId;
  final DateTime? createdAt;

  GradeItem({required this.grade, required this.professorId, this.createdAt});

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    return GradeItem(
      grade: json['grade'] ?? 0,
      professorId: json['professor'] ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
