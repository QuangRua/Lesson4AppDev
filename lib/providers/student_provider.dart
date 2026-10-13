import 'package:flutter/material.dart';
import '../database/student_database.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final StudentDatabase _db = StudentDatabase.instance;

  List<Student> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Locale? _currentLocale; // null = follow system

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  Locale? get currentLocale => _currentLocale;

  StudentProvider() {
    loadStudents();
  }

  // Tải danh sách sinh viên từ SQLite
  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_searchQuery.trim().isEmpty) {
        _students = await _db.getAllStudents();
      } else {
        _students = await _db.searchStudents(_searchQuery);
      }
    } catch (e) {
      debugPrint('Error loading students: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm sinh viên
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadStudents();
  }

  // Thêm sinh viên mới
  Future<Student> addStudent(Student student) async {
    final created = await _db.create(student);
    await loadStudents();
    return created;
  }

  // Sửa thông tin sinh viên
  Future<bool> updateStudent(Student student) async {
    final rowsAffected = await _db.update(student);
    if (rowsAffected > 0) {
      await loadStudents();
      return true;
    }
    return false;
  }

  // Xóa sinh viên
  Future<bool> deleteStudent(int id) async {
    final rowsAffected = await _db.delete(id);
    if (rowsAffected > 0) {
      await loadStudents();
      return true;
    }
    return false;
  }

  // Kiểm tra trùng mã sinh viên
  Future<bool> checkStudentIdExists(String studentId, {int? excludeId}) async {
    return await _db.studentIdExists(studentId, excludeId: excludeId);
  }

  // Nạp dữ liệu mẫu
  Future<void> seedSampleData() async {
    await _db.seedSampleData();
    await loadStudents();
  }

  // Lấy chi tiết 1 sinh viên (refresh nếu cần)
  Future<Student?> getStudentById(int id) async {
    return await _db.getStudentById(id);
  }

  // Đổi ngôn ngữ
  void setLocale(Locale? locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    if (_currentLocale?.languageCode == 'en') {
      _currentLocale = const Locale('vi');
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }
}
