import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../service/petition_service.dart';
import '../../../core/enums/petition_enums.dart';
import '../../../untils/app_colors.dart';
import '../../../helper/date_helper.dart';
import '../../../core/utils/app_file_downloader.dart';

class PetitionInfoTab extends StatelessWidget {
  final PetitionItemModel petition;
  final bool isDark;

  const PetitionInfoTab({
    super.key,
    required this.petition,
    required this.isDark,
  });

  String _getStatusLabel(String status) {
    return PetitionProcessingStatus.fromKey(status).label;
  }

  @override
  Widget build(BuildContext context) {
    final attachments = petition.attachments ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. NỘI DUNG ĐƠN
          Row(
            children: [
              Icon(Icons.subject, size: 15, color: AppColors.grey[500]),
              const SizedBox(width: 6),
              Text(
                'NỘI DUNG ĐƠN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey[500],
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            petition.content.isNotEmpty ? petition.content : 'Không có nội dung chi tiết',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.white70 : AppColors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 2. LƯỚI THÔNG TIN 2 CỘT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột trái
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.timeline,
                      label: 'TRẠNG THÁI',
                      value: _getStatusLabel(petition.processingStatus),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'NGƯỜI GỬI ĐƠN',
                      value: petition.senderName,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoItem(
                      icon: Icons.badge_outlined,
                      label: 'CCCD',
                      value: petition.senderCccd != null && petition.senderCccd!.isNotEmpty
                          ? petition.senderCccd!
                          : '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Cột phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.apartment_outlined,
                      label: 'PHÒNG BAN XỬ LÝ',
                      value: petition.departmentName.isNotEmpty
                          ? petition.departmentName
                          : 'Chưa phân công',
                    ),
                    const SizedBox(height: 14),
                    _buildInfoItem(
                      icon: Icons.phone_outlined,
                      label: 'SỐ ĐIỆN THOẠI',
                      value: petition.senderPhone != null && petition.senderPhone!.isNotEmpty
                          ? petition.senderPhone!
                          : '-',
                    ),
                    const SizedBox(height: 14),
                    _buildInfoItem(
                      icon: Icons.mail_outline,
                      label: 'EMAIL',
                      value: petition.senderEmail != null && petition.senderEmail!.isNotEmpty
                          ? petition.senderEmail!
                          : '-',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Địa chỉ (Row riêng)
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            label: 'ĐỊA CHỈ',
            value: petition.senderAddress != null && petition.senderAddress!.isNotEmpty
                ? petition.senderAddress!
                : '-',
          ),
          const SizedBox(height: 14),

          // Ngày gửi đơn & Hạn xử lý
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'NGÀY GỬI ĐƠN',
                  value: DateHelper.formatDate(petition.submissionDate, fallback: '-'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'HẠN XỬ LÝ',
                  value: DateHelper.formatDate(petition.deadlineDate, fallback: '-'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. TỆP ĐÍNH KÈM ĐƠN THƯ
          Row(
            children: [
              Icon(Icons.attach_file, size: 15, color: AppColors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'TỆP ĐÍNH KÈM ĐƠN THƯ (${attachments.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey[500],
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (attachments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Không có tệp đính kèm',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.white70 : AppColors.grey[500]),
              ),
            )
          else
            ...attachments.map((file) {
              final String fileName = file is Map
                  ? (file['name'] ?? file['file_name'] ?? file['path'] ?? 'Tệp đính kèm').toString()
                  : file.toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white10 : AppColors.badgeBlueBg.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.white10 : AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final String fileUrl = file is Map
                            ? (file['url'] ?? file['download_url'] ?? file['file_url'] ?? file['path'] ?? '').toString()
                            : file.toString();
                        AppFileDownloader.downloadAndOpen(
                          fileUrl: fileUrl,
                          customFileName: fileName,
                        );
                      },
                      child: const Text(
                        'Mở / Tải về',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.grey[500],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
