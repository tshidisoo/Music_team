import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assignedBy; // teacherId
  final List<String> mediaAllowed;
  final bool isActive;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignedBy,
    this.mediaAllowed = const ['video', 'audio', 'pdf', 'image'],
    this.isActive = true,
    required this.createdAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      assignedBy: data['assignedBy'] ?? '',
      mediaAllowed: List<String>.from(
          data['mediaAllowed'] ?? ['video', 'audio', 'pdf', 'image']),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'assignedBy': assignedBy,
        'mediaAllowed': mediaAllowed,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  bool get isPastDue => DateTime.now().isAfter(dueDate);

  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;
}

class MediaFile {
  final String url;
  final String type; // 'video', 'audio', 'pdf', 'image'
  final String fileName;
  final int size; // bytes

  const MediaFile({
    required this.url,
    required this.type,
    required this.fileName,
    required this.size,
  });

  factory MediaFile.fromMap(Map<String, dynamic> map) => MediaFile(
        url: map['url'] ?? '',
        type: map['type'] ?? '',
        fileName: map['fileName'] ?? '',
        size: (map['size'] ?? 0) as int,
      );

  Map<String, dynamic> toMap() => {
        'url': url,
        'type': type,
        'fileName': fileName,
        'size': size,
      };

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class SubmissionModel {
  final String id;
  final String projectId;
  final String studentId;
  final String studentName;
  final List<MediaFile> mediaFiles;
  final String? notes;
  final DateTime submittedAt;
  final String? grade;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;

  const SubmissionModel({
    required this.id,
    required this.projectId,
    required this.studentId,
    required this.studentName,
    this.mediaFiles = const [],
    this.notes,
    required this.submittedAt,
    this.grade,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
  });

  bool get isGraded => grade != null || feedback != null;

  factory SubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubmissionModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      mediaFiles: (data['mediaFiles'] as List<dynamic>? ?? [])
          .map((e) => MediaFile.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      notes: data['notes'],
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      grade: data['grade'],
      feedback: data['feedback'],
      gradedAt: data['gradedAt'] != null
          ? (data['gradedAt'] as Timestamp).toDate()
          : null,
      gradedBy: data['gradedBy'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'projectId': projectId,
        'studentId': studentId,
        'studentName': studentName,
        'mediaFiles': mediaFiles.map((f) => f.toMap()).toList(),
        'notes': notes,
        'submittedAt': Timestamp.fromDate(submittedAt),
        'grade': grade,
        'feedback': feedback,
        'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
        'gradedBy': gradedBy,
      };
}
