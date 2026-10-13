import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isVietnamese => locale.languageCode == 'vi';

  // --- Strings Dictionary ---
  static const Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'app_title': 'Quản lý Sinh viên',
      'student_list': 'Danh sách sinh viên',
      'student_detail': 'Chi tiết sinh viên',
      'add_student': 'Thêm sinh viên mới',
      'edit_student': 'Sửa thông tin SV',
      'search_hint': 'Tìm theo họ tên hoặc MSSV...',
      'no_students': 'Chưa có sinh viên nào',
      'no_students_sub': 'Hãy thêm sinh viên đầu tiên hoặc tải dữ liệu mẫu.',
      'seed_sample_data': 'Tạo dữ liệu mẫu',
      'sample_data_added': 'Đã nạp 5 sinh viên mẫu thành công!',
      'total_students': 'Tổng số sinh viên',
      'student_name': 'Họ tên SV',
      'student_id': 'Mã số SV',
      'student_email': 'Email',
      'student_avatar': 'Ảnh avatar SV',
      'avatar_url_hint': 'Nhập link ảnh (URL) hoặc chọn ảnh từ máy...',
      'avatar_url_label': 'Đường dẫn ảnh trực tuyến (URL)',
      'pick_from_device': 'Chọn ảnh từ thiết bị',
      'pick_from_gallery': 'Chọn từ thư viện',
      'take_photo': 'Chụp ảnh mới',
      'preview_avatar': 'Xem trước ảnh',
      'quick_suggest_avatars': 'Gợi ý avatar mẫu:',
      'save': 'Lưu thông tin',
      'cancel': 'Hủy bỏ',
      'yes': 'Có',
      'no': 'Không',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'confirm_delete_title': 'Xác nhận xóa',
      'confirm_delete_message': 'Bạn có muốn xóa thông tin SV không?',
      'confirm_edit_title': 'Xác nhận sửa',
      'confirm_edit_message': 'Bạn có muốn sửa thông tin SV không?',
      'deleted_success': 'Đã xóa sinh viên thành công!',
      'updated_success': 'Đã cập nhật thông tin sinh viên thành công!',
      'added_success': 'Đã thêm sinh viên mới thành công!',
      'error_name_empty': 'Vui lòng nhập họ tên sinh viên',
      'error_id_empty': 'Vui lòng nhập mã số sinh viên',
      'error_id_exists': 'Mã số sinh viên này đã tồn tại trong hệ thống',
      'error_email_empty': 'Vui lòng nhập địa chỉ email',
      'error_email_invalid': 'Email không hợp lệ (ví dụ: sv@school.edu.vn)',
      'error_avatar_empty': 'Vui lòng chọn ảnh đại diện hoặc nhập link ảnh',
      'created_at': 'Ngày tạo',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'toggle_lang': 'Đổi ngôn ngữ',
      'back': 'Quay lại',
      'copy_email': 'Sao chép email',
      'email_copied': 'Đã sao chép email vào bộ nhớ tạm',
      'email_hint': 'vd: ten.sv@st.cmcu.edu.vn',
      'error': 'Lỗi',
      'error_pick_image': 'Lỗi chọn ảnh',
    },
    'en': {
      'app_title': 'Student Manager',
      'student_list': 'Student List',
      'student_detail': 'Student Details',
      'add_student': 'Add New Student',
      'edit_student': 'Edit Student Info',
      'search_hint': 'Search by name or student ID...',
      'no_students': 'No students found',
      'no_students_sub': 'Add your first student or load sample data.',
      'seed_sample_data': 'Load Sample Data',
      'sample_data_added': 'Successfully loaded 5 sample students!',
      'total_students': 'Total students',
      'student_name': 'Full Name',
      'student_id': 'Student ID',
      'student_email': 'Email',
      'student_avatar': 'Avatar Image',
      'avatar_url_hint': 'https://example.com/avatar.jpg',
      'avatar_url_label': 'Online Image Link (URL)',
      'pick_from_device': 'Select image from device',
      'pick_from_gallery': 'Pick from Gallery',
      'take_photo': 'Take a Photo',
      'preview_avatar': 'Preview Avatar',
      'quick_suggest_avatars': 'Suggested avatars:',
      'save': 'Save Info',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'no': 'No',
      'delete': 'Delete',
      'edit': 'Edit',
      'confirm_delete_title': 'Confirm Deletion',
      'confirm_delete_message': 'Do you want to delete this student?',
      'confirm_edit_title': 'Confirm Update',
      'confirm_edit_message': 'Do you want to update this student?',
      'deleted_success': 'Student deleted successfully!',
      'updated_success': 'Student information updated successfully!',
      'added_success': 'New student added successfully!',
      'error_name_empty': 'Please enter student full name',
      'error_id_empty': 'Please enter student ID',
      'error_id_exists': 'This student ID already exists in the system',
      'error_email_empty': 'Please enter email address',
      'error_email_invalid': 'Invalid email address (e.g. student@school.edu)',
      'error_avatar_empty': 'Please choose an avatar or enter an image URL',
      'created_at': 'Created at',
      'language': 'Language',
      'vietnamese': 'Vietnamese',
      'english': 'English',
      'toggle_lang': 'Change Language',
      'back': 'Back',
      'copy_email': 'Copy email',
      'email_copied': 'Email copied to clipboard',
      'email_hint': 'e.g: name.student@st.cmcu.edu.vn',
      'error': 'Error',
      'error_pick_image': 'Error picking image',
    },
  };

  String translate(String key) {
    final lang = locale.languageCode == 'vi' ? 'vi' : 'en';
    return _localizedValues[lang]?[key] ?? _localizedValues['vi']?[key] ?? key;
  }

  // Helper getters
  String get appTitle => translate('app_title');
  String get studentList => translate('student_list');
  String get studentDetail => translate('student_detail');
  String get addStudent => translate('add_student');
  String get editStudent => translate('edit_student');
  String get searchHint => translate('search_hint');
  String get noStudents => translate('no_students');
  String get noStudentsSub => translate('no_students_sub');
  String get seedSampleData => translate('seed_sample_data');
  String get sampleDataAdded => translate('sample_data_added');
  String get totalStudents => translate('total_students');
  String get studentName => translate('student_name');
  String get studentId => translate('student_id');
  String get studentEmail => translate('student_email');
  String get studentAvatar => translate('student_avatar');
  String get avatarUrlHint => translate('avatar_url_hint');
  String get avatarUrlLabel => translate('avatar_url_label');
  String get pickFromDevice => translate('pick_from_device');
  String get pickFromGallery => translate('pick_from_gallery');
  String get takePhoto => translate('take_photo');
  String get previewAvatar => translate('preview_avatar');
  String get quickSuggestAvatars => translate('quick_suggest_avatars');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get yes => translate('yes');
  String get no => translate('no');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get confirmDeleteTitle => translate('confirm_delete_title');
  String get confirmDeleteMessage => translate('confirm_delete_message');
  String get confirmEditTitle => translate('confirm_edit_title');
  String get confirmEditMessage => translate('confirm_edit_message');
  String get deletedSuccess => translate('deleted_success');
  String get updatedSuccess => translate('updated_success');
  String get addedSuccess => translate('added_success');
  String get errorNameEmpty => translate('error_name_empty');
  String get errorIdEmpty => translate('error_id_empty');
  String get errorIdExists => translate('error_id_exists');
  String get errorEmailEmpty => translate('error_email_empty');
  String get errorEmailInvalid => translate('error_email_invalid');
  String get errorAvatarEmpty => translate('error_avatar_empty');
  String get createdAt => translate('created_at');
  String get language => translate('language');
  String get vietnamese => translate('vietnamese');
  String get english => translate('english');
  String get toggleLang => translate('toggle_lang');
  String get back => translate('back');
  String get copyEmail => translate('copy_email');
  String get emailCopied => translate('email_copied');
  String get emailHint => translate('email_hint');
  String get error => translate('error');
  String get errorPickImage => translate('error_pick_image');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
