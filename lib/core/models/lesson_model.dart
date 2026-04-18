import 'package:cloud_firestore/cloud_firestore.dart';

class LessonContent {
  final String text;
  final List<String> imageUrls;
  final List<String> keyPoints;

  const LessonContent({
    required this.text,
    this.imageUrls = const [],
    this.keyPoints = const [],
  });

  factory LessonContent.fromMap(Map<String, dynamic> map) => LessonContent(
        text: map['text'] ?? '',
        imageUrls: List<String>.from(map['imageUrls'] ?? []),
        keyPoints: List<String>.from(map['keyPoints'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'text': text,
        'imageUrls': imageUrls,
        'keyPoints': keyPoints,
      };
}

class LessonModel {
  final String id;
  final String title;
  final int chapterNumber;
  final int partNumber; // 1 or 2
  final int order; // sort order within the part
  final LessonContent content;
  final List<String> linkedExerciseIds;
  final String? thumbnailUrl;
  final String? iconName; // Material icon name string

  const LessonModel({
    required this.id,
    required this.title,
    required this.chapterNumber,
    required this.partNumber,
    required this.order,
    required this.content,
    this.linkedExerciseIds = const [],
    this.thumbnailUrl,
    this.iconName,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      title: data['title'] ?? '',
      chapterNumber: (data['chapterNumber'] ?? 0) as int,
      partNumber: (data['partNumber'] ?? 1) as int,
      order: (data['order'] ?? 0) as int,
      content: LessonContent.fromMap(
        Map<String, dynamic>.from(data['content'] ?? {}),
      ),
      linkedExerciseIds: List<String>.from(data['linkedExerciseIds'] ?? []),
      thumbnailUrl: data['thumbnailUrl'],
      iconName: data['iconName'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'chapterNumber': chapterNumber,
        'partNumber': partNumber,
        'order': order,
        'content': content.toMap(),
        'linkedExerciseIds': linkedExerciseIds,
        'thumbnailUrl': thumbnailUrl,
        'iconName': iconName,
      };
}

class LessonProgress {
  final String lessonId;
  final bool completed;
  final DateTime? completedAt;
  final int? score;

  const LessonProgress({
    required this.lessonId,
    this.completed = false,
    this.completedAt,
    this.score,
  });

  factory LessonProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonProgress(
      lessonId: doc.id,
      completed: data['completed'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      score: data['score'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'completed': completed,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'score': score,
      };
}
