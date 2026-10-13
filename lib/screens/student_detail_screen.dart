import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/student_avatar.dart';
import 'student_form_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final int studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  Future<void> _handleDelete(BuildContext context, Student student) async {
    final confirmed = await showStudentConfirmDialog(
      context,
      type: ConfirmActionType.delete,
    );

    if (confirmed && context.mounted) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context);
      final success = await provider.deleteStudent(student.id!);
      if (success && context.mounted) {
        Navigator.pop(context); // Quay lại Trang 1
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.deletedSuccess),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _formatDate(String isoString, String locale) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat.yMMMMd(locale).add_jm().format(date);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = Provider.of<StudentProvider>(context);

    // Tìm sinh viên trong provider
    final studentList = provider.students.where((s) => s.id == studentId);
    if (studentList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.studentDetail)),
        body: Center(
          child: Text(l10n.noStudents),
        ),
      );
    }

    final student = studentList.first;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.studentDetail,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nút Sửa trên AppBar
          IconButton(
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentFormScreen(student: student),
                ),
              );
            },
          ),
          // Nút Xóa trên AppBar
          IconButton(
            tooltip: l10n.delete,
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            onPressed: () => _handleDelete(context, student),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Avatar Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withAlpha(120),
                    theme.colorScheme.surfaceContainerLow,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(70),
                ),
              ),
              child: Column(
                children: [
                  // Avatar lớn với Hero tag
                  StudentAvatar(
                    avatar: student.avatar,
                    name: student.name,
                    radius: 56,
                    enableHero: true,
                    heroTag: 'student_avatar_${student.id}',
                  ),
                  const SizedBox(height: 16),

                  // Họ tên
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mã số sinh viên
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.studentId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Thông tin chi tiết Cards
            _buildInfoCard(
              context,
              icon: Icons.person_rounded,
              title: l10n.studentName,
              value: student.name,
              theme: theme,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.badge_rounded,
              title: l10n.studentId,
              value: student.studentId,
              theme: theme,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.email_rounded,
              title: l10n.studentEmail,
              value: student.email,
              theme: theme,
              trailing: IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: l10n.copyEmail,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: student.email));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.emailCopied),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.access_time_rounded,
              title: l10n.createdAt,
              value: _formatDate(student.createdAt, l10n.locale.languageCode),
              theme: theme,
            ),
            const SizedBox(height: 32),

            // Nút bấm hành động bên dưới (Sửa & Xóa)
            Row(
              children: [
                // Nút Xóa
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.colorScheme.error),
                      foregroundColor: theme.colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _handleDelete(context, student),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(
                      l10n.delete,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Nút Sửa
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentFormScreen(student: student),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: Text(
                      l10n.edit,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(70),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(120),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
