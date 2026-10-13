import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/student_avatar.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    Provider.of<StudentProvider>(context, listen: false).setSearchQuery(value);
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  Text(
                    l10n.studentList,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Nút đổi nhanh ngôn ngữ VI / EN
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              avatar: const Icon(Icons.language_rounded, size: 16),
              label: Text(
                l10n.isVietnamese ? 'VI' : 'EN',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                provider.toggleLocale();
              },
              backgroundColor: theme.colorScheme.secondaryContainer.withAlpha(160),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm & thống kê
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withAlpha(30),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Thanh thống kê số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.totalStudents}: ${provider.students.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                    if (provider.students.isEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                        label: Text(l10n.seedSampleData),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () async {
                          await provider.seedSampleData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.sampleDataAdded),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Danh sách Sinh viên
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.students.isEmpty
                    ? _buildEmptyState(context, l10n, theme, provider)
                    : RefreshIndicator(
                        onRefresh: () => provider.loadStudents(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: provider.students.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = provider.students[index];
                            return _buildStudentCard(
                              context,
                              student,
                              theme,
                              l10n,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mở Trang 3 ở chế độ Thêm mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          l10n.addStudent,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    StudentProvider provider,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noStudents,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noStudentsSub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await provider.seedSampleData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.sampleDataAdded),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: Text(l10n.seedSampleData),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    Student student,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // Yêu cầu: Click vào item trong Trang 1 sẽ mở Trang 2 (Chi tiết sinh viên)
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailScreen(studentId: student.id!),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(80),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar với Hero animation sang Trang 2
                StudentAvatar(
                  avatar: student.avatar,
                  name: student.name,
                  radius: 28,
                  enableHero: true,
                  heroTag: 'student_avatar_${student.id}',
                ),
                const SizedBox(width: 14),

                // Thông tin: Tên, MSSV, Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Họ tên
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Mã số sinh viên badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              student.studentId,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurface.withAlpha(140),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              student.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withAlpha(160),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Menu (Xóa nhanh hoặc Sửa nhanh)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentFormScreen(student: student),
                        ),
                      );
                    } else if (value == 'delete') {
                      await _handleDelete(context, student);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(l10n.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: theme.colorScheme.error),
                          const SizedBox(width: 10),
                          Text(
                            l10n.delete,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
