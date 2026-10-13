import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n/app_localizations.dart';
import 'providers/student_provider.dart';
import 'screens/student_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hỗ trợ SQLite chạy trên Desktop (Windows / Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => StudentProvider(),
      child: const StudentApp(),
    ),
  );
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý Sinh viên',

      // Đa ngôn ngữ: Tự động theo thiết bị hoặc chuyển đổi thủ công
      locale: provider.currentLocale,
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Mặc định tiếng Việt nếu thiết bị không thuộc ngôn ngữ hỗ trợ
        return const Locale('vi', 'VN');
      },

      // Giao diện Material 3 sang trọng, tinh tế
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo tone
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF0284C7),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.8),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF818CF8),
          surface: const Color(0xFF0F172A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,

      // Màn hình khởi đầu: Trang 1 (Danh sách sinh viên)
      home: const StudentListScreen(),
    );
  }
}
