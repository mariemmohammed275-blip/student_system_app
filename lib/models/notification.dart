class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool seen;
  final String type;
  final String createdAt;
  final String? startTime;
  final String? endTime;

  final String? meetingUrl;
  final String? courseName;

  final Map<String, dynamic>? postedBy;
  final Map<String, dynamic>? course;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.seen,
    required this.type,
    required this.createdAt,
    this.meetingUrl,
    this.courseName,
    this.postedBy,
    this.course,
    this.startTime,
    this.endTime,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      // Look for 'message', if null look for 'content', else default
      message: json['message'] ?? json['content'] ?? 'No Content',
      seen: json['seen'] ?? false,
      type: json['type'] ?? '',
      // Fallback for different date key formats
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      meetingUrl: json['meeting'] != null
          ? json['meeting']['meetingUrl']
          : null,
      courseName: json['course'] != null ? json['course']['name'] : null,
      postedBy: json['posted_by'] is Map<String, dynamic>
          ? json['posted_by']
          : null,
      course: json['course'] is Map<String, dynamic> ? json['course'] : null,
      startTime: json['meeting'] != null ? json['meeting']['startsAt'] : null,
      endTime: json['meeting'] != null ? json['meeting']['endsAt'] : null,
    );
  }
}
