import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// PHÂN LOẠI ĐỊNH DẠNG TỆP ĐÍNH KÈM (FILE ATTACHMENT TYPE)
/// ============================================================================
enum FileAttachmentType {
  pdf(
    label: 'PDF',
    icon: Icons.picture_as_pdf,
    color: AppColors.red,
    extensions: ['pdf'],
  ),
  excel(
    label: 'Excel',
    icon: Icons.table_chart_outlined,
    color: AppColors.green,
    extensions: ['xls', 'xlsx', 'csv'],
  ),
  word(
    label: 'Word',
    icon: Icons.description_outlined,
    color: AppColors.blue,
    extensions: ['doc', 'docx', 'odt'],
  ),
  powerpoint(
    label: 'PowerPoint',
    icon: Icons.slideshow_outlined,
    color: AppColors.orange,
    extensions: ['ppt', 'pptx'],
  ),
  image(
    label: 'Hình ảnh',
    icon: Icons.image_outlined,
    color: AppColors.purple,
    extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'],
  ),
  zip(
    label: 'Tệp nén',
    icon: Icons.folder_zip_outlined,
    color: AppColors.warningOrange,
    extensions: ['zip', 'rar', '7z', 'tar', 'gz'],
  ),
  video(
    label: 'Video',
    icon: Icons.videocam_outlined,
    color: AppColors.priorityUrgent,
    extensions: ['mp4', 'mov', 'avi', 'mkv', 'flv'],
  ),
  audio(
    label: 'Âm thanh',
    icon: Icons.audiotrack_outlined,
    color: AppColors.primary,
    extensions: ['mp3', 'wav', 'aac', 'm4a', 'flac'],
  ),
  link(
    label: 'Liên kết web',
    icon: Icons.link,
    color: AppColors.primary,
    extensions: ['http', 'https', 'link', 'url'],
  ),
  other(
    label: 'Tệp tin',
    icon: Icons.attach_file,
    color: AppColors.grey,
    extensions: [],
  );

  final String label;
  final IconData icon;
  final Color color;
  final List<String> extensions;

  const FileAttachmentType({
    required this.label,
    required this.icon,
    required this.color,
    required this.extensions,
  });

  static final Map<String, FileAttachmentType> _extensionMap = () {
    final map = <String, FileAttachmentType>{};
    for (final type in FileAttachmentType.values) {
      for (final ext in type.extensions) {
        map[ext.toLowerCase()] = type;
      }
    }
    return map;
  }();

  /// Tự động nhận diện định dạng từ tên tệp hoặc đường dẫn URL
  static FileAttachmentType fromFileName(String? fileNameOrUrl) {
    if (fileNameOrUrl == null || fileNameOrUrl.trim().isEmpty) {
      return FileAttachmentType.other;
    }

    final trimmed = fileNameOrUrl.trim().toLowerCase();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      // Nếu là url nhưng có đuôi tệp cụ thể ở cuối
      final uri = Uri.tryParse(trimmed);
      final lastSegment = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : '';
      if (lastSegment.contains('.')) {
        final ext = lastSegment.split('.').last.toLowerCase();
        return _extensionMap[ext] ?? FileAttachmentType.link;
      }
      return FileAttachmentType.link;
    }

    if (trimmed.contains('.')) {
      final ext = trimmed.split('.').last.toLowerCase();
      return _extensionMap[ext] ?? FileAttachmentType.other;
    }

    return _extensionMap[trimmed] ?? FileAttachmentType.other;
  }
}
