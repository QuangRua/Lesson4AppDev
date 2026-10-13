import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';

class StudentDatabase {
  static final StudentDatabase instance = StudentDatabase._init();
  static Database? _database;

  StudentDatabase._init();

  static const String tableName = 'students';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Thêm dữ liệu mẫu ban đầu để app hiển thị đẹp mắt ngay khi mở
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final sampleStudents = [
      Student(
        studentId: 'SV2024001',
        name: 'Nguyễn Văn An',
        email: 'an.nguyen@university.edu.vn',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      ),
      Student(
        studentId: 'SV2024002',
        name: 'Trần Thị Bích Ngọc',
        email: 'ngoc.tran@university.edu.vn',
        avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      ),
      Student(
        studentId: 'SV2024003',
        name: 'Lê Hoàng Minh',
        email: 'minh.le@university.edu.vn',
        avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
      Student(
        studentId: 'SV2024004',
        name: 'Phạm Thu Trang',
        email: 'trang.pham@university.edu.vn',
        avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
      Student(
        studentId: 'SV2024005',
        name: 'Đặng Tuấn Kiệt',
        email: 'kiet.dang@university.edu.vn',
        avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
    ];

    for (final s in sampleStudents) {
      await db.insert(
        tableName,
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // --- CRUD Operations ---

  // 1. CREATE
  Future<Student> create(Student student) async {
    final db = await instance.database;
    final id = await db.insert(
      tableName,
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return student.copyWith(id: id);
  }

  // 2. READ ALL
  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final result = await db.query(tableName, orderBy: 'id DESC');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  // 2b. READ BY ID
  Future<Student?> getStudentById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  // 2c. CHECK IF STUDENT ID EXISTS (excluding current student id for edits)
  Future<bool> studentIdExists(String studentId, {int? excludeId}) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
      where: excludeId != null ? 'student_id = ? AND id != ?' : 'student_id = ?',
      whereArgs: excludeId != null ? [studentId.trim(), excludeId] : [studentId.trim()],
    );
    return maps.isNotEmpty;
  }

  // 2d. SEARCH BY NAME OR STUDENT ID
  Future<List<Student>> searchStudents(String query) async {
    final db = await instance.database;
    final q = '%${query.trim()}%';
    final result = await db.query(
      tableName,
      where: 'name LIKE ? OR student_id LIKE ? OR email LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'id DESC',
    );
    return result.map((map) => Student.fromMap(map)).toList();
  }

  // 3. UPDATE
  Future<int> update(Student student) async {
    final db = await instance.database;
    return await db.update(
      tableName,
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // 4. DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // SEED SAMPLE DATA (User triggerable if database is empty)
  Future<void> seedSampleData() async {
    final db = await instance.database;
    await _insertInitialData(db);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
