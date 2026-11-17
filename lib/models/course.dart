class Course {
  final String id;
  final String tutorId;
  final String title;
  final String description;
  final String category;
  final String? thumbnailUrl;
  final bool isFree;
  final double price;
  final String? videoUrl;
  final int studentCount;
  final double rating;

  const Course({
    required this.id,
    required this.tutorId,
    required this.title,
    required this.description,
    required this.category,
    this.thumbnailUrl,
    required this.isFree,
    required this.price,
    this.videoUrl,
    this.studentCount = 0,
    this.rating = 0,
  });

  factory Course.fromMap(Map<String, dynamic> map) => Course(
    id: map['id'].toString(),
    tutorId: map['tutor_id'].toString(),
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? 'General',
    thumbnailUrl: map['thumbnail_url'],
    isFree: map['is_free'] == true,
    price: (map['price'] as num?)?.toDouble() ?? 0,
    videoUrl: map['video_url'],
    studentCount: (map['student_count'] as num?)?.toInt() ?? 0,
    rating: (map['rating'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toInsertMap() => {
    'title': title,
    'description': description,
    'category': category,
    'thumbnail_url': thumbnailUrl,
    'is_free': isFree,
    'price': price,
    'tutor_id': tutorId,
  };
}
