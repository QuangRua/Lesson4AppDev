import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/student_avatar.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student; // null nếu là Thêm mới, khác null nếu là Sửa

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _emailController;
  late TextEditingController _avatarController;

  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;



  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _studentIdController = TextEditingController(text: widget.student?.studentId ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _avatarController = TextEditingController(text: widget.student?.avatar ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  // Chọn ảnh từ thiết bị qua ImagePicker
  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarController.text = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorPickImage}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Hiển thị modal sheet chọn ảnh từ máy hoặc camera
  void _showImageSourceDialog(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(l10n.pickFromGallery),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: Text(l10n.takePhoto),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Xử lý Lưu thông tin
  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context);
    final provider = Provider.of<StudentProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final studentIdInput = _studentIdController.text.trim();

    // Kiểm tra trùng Mã số sinh viên
    final exists = await provider.checkStudentIdExists(
      studentIdInput,
      excludeId: widget.student?.id,
    );
    if (!mounted) return;

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorIdExists),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final avatarPath = _avatarController.text.trim();

    // YÊU CẦU ĐẶC BIỆT: Nếu là SỬA THÔNG TIN SV -> Bật hộp thoại xác nhận:
    // "Bạn có muốn sửa thông tin SV không?" -> User click "Có" mới sửa.
    if (isEditing) {
      final confirmed = await showStudentConfirmDialog(
        context,
        type: ConfirmActionType.edit,
      );
      if (!mounted) return;

      if (!confirmed) {
        // User chọn "Không", không thực hiện sửa
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      if (isEditing) {
        final updatedStudent = widget.student!.copyWith(
          studentId: studentIdInput,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatar: avatarPath,
        );
        await provider.updateStudent(updatedStudent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.updatedSuccess),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context); // Quay về
        }
      } else {
        final newStudent = Student(
          studentId: studentIdInput,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatar: avatarPath,
        );
        await provider.addStudent(newStudent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.addedSuccess),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context); // Quay về
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editStudent : l10n.addStudent,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Avatar Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _nameController,
                          builder: (context, nameValue, _) {
                            return ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _avatarController,
                              builder: (context, avatarValue, __) {
                                return StudentAvatar(
                                  avatar: avatarValue.text,
                                  name: nameValue.text.isNotEmpty
                                      ? nameValue.text
                                      : 'SV',
                                  radius: 54,
                                );
                              },
                            );
                          },
                        ),
                        Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _showImageSourceDialog(l10n),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.studentAvatar,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trường 1: Họ tên SV
              Text(
                l10n.studentName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorNameEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trường 2: Mã số SV
              Text(
                l10n.studentId,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _studentIdController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorIdEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trường 3: Email
              Text(
                l10n.studentEmail,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: l10n.emailHint,
                  prefixIcon: const Icon(Icons.email_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.errorEmailEmpty;
                  }
                  final emailRegex = RegExp(r'^[\w\.\-]+@st\.cmcu\.edu\.vn$');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return l10n.errorEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trường 4: Ảnh Avatar (link ảnh hoặc upload từ thiết bị)
              Text(
                l10n.studentAvatar,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _avatarController,
                decoration: InputDecoration(
                  hintText: l10n.avatarUrlHint,
                  prefixIcon: const Icon(Icons.link_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                    tooltip: l10n.pickFromDevice,
                    onPressed: () => _showImageSourceDialog(l10n),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: null,
              ),
              const SizedBox(height: 10),

              // Nút bấm tiện ích chọn ảnh từ máy
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _showImageSourceDialog(l10n),
                    icon: const Icon(Icons.image_search_rounded, size: 18),
                    label: Text(l10n.pickFromDevice),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Nút Lưu thông tin
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSaving ? null : _handleSubmit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isEditing ? Icons.save_rounded : Icons.person_add_rounded),
                          const SizedBox(width: 8),
                          Text(
                            l10n.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
