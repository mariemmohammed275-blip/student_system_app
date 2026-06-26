class FacultyEvent {
  final String id;
  final String title;
  final String location;
  final String date;
  final String startTime;
  final String endTime;
  final String image;
  final String description;
  final String link;

  FacultyEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.image,
    required this.description,
    required this.link,
  });

  factory FacultyEvent.fromJson(Map<String, dynamic> json) {
    // Extracting the date part (YYYY-MM-DD) from the ISO string
    String formattedDate = '';
    if (json['date'] != null) {
      formattedDate = json['date'].toString().split('T')[0];
    }

    return FacultyEvent(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      location: json['venue'] ?? 'No Location',
      date: formattedDate,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      image: json['image_url'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
    );
  }
}
