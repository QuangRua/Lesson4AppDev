class Student {
  final int? id;
  final String studentId;
  final String name;
  final String email;
  final String avatar;
  final String createdAt;

  Student({
    this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.avatar,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'student_id': studentId.trim(),
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'avatar': avatar.trim(),
      'created_at': createdAt,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      studentId: map['student_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  Student copyWith({
    int? id,
    String? studentId,
    String? name,
    String? email,
    String? avatar,
    String? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
