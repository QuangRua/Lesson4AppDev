import 'package:flutter_test/flutter_test.dart';
import 'package:student_manager/models/student.dart';

void main() {
  test('Student model serialization and deserialization', () {
    final student = Student(
      id: 1,
      studentId: 'SV2024001',
      name: 'Nguyen Van An',
      email: 'an.nguyen@university.edu.vn',
      avatar: 'https://example.com/avatar.jpg',
      createdAt: '2024-01-01T00:00:00.000',
    );

    final map = student.toMap();
    expect(map['id'], 1);
    expect(map['student_id'], 'SV2024001');
    expect(map['name'], 'Nguyen Van An');
    expect(map['email'], 'an.nguyen@university.edu.vn');
    expect(map['avatar'], 'https://example.com/avatar.jpg');

    final reconstructed = Student.fromMap(map);
    expect(reconstructed.id, 1);
    expect(reconstructed.studentId, 'SV2024001');
    expect(reconstructed.name, 'Nguyen Van An');
    expect(reconstructed.email, 'an.nguyen@university.edu.vn');
    expect(reconstructed.avatar, 'https://example.com/avatar.jpg');
  });
}
