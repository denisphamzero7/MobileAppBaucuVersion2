import 'package:flutter/material.dart';
import '../../../service/petition_service.dart';
import '../../../untils/app_colors.dart';
import '../../../helper/date_helper.dart';

class PetitionResultTab extends StatelessWidget {
  final PetitionItemModel petition;
  final bool isDark;

  const PetitionResultTab({
    super.key,
    required this.petition,
    required this.isDark,
  });

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'todo':
        return 'Mới tiếp nhận';
      case 'processing':
      case 'in_progress':
        return 'Đang xử lý';
      case 'completed':
      case 'done':
        return 'Đã hoàn thành';
      case 'paused':
        return 'Tạm dừng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return AppColors.badgeGreenBg;
      case 'processing':
      case 'in_progress':
        return AppColors.badgeBlueBg;
      case 'paused':
        return AppColors.bgYellowLight;
      case 'cancelled':
        return AppColors.badgeRedBg;
      default:
        return isDark ? AppColors.white10 : AppColors.borderLight;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return AppColors.textGreen;
      case 'processing':
      case 'in_progress':
        return AppColors.primary;
      case 'paused':
        return AppColors.warningOrange;
      case 'cancelled':
        return AppColors.dangerText;
      default:
        return isDark ? AppColors.white70 : AppColors.textGrayDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.borderGrey,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TRẠNG THÁI XỬ LÝ ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRẠNG THÁI XỬ LÝ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white70 : AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(petition.processingStatus),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(petition.processingStatus),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusTextColor(petition.processingStatus),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. NGÀY HOÀN THÀNH & SỐ KÝ HIỆU VĂN BẢN (2 Cột)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'NGÀY HOÀN THÀNH',
                  value: petition.completedAt != null && petition.completedAt!.isNotEmpty
                      ? DateHelper.formatDate(petition.completedAt, fallback: '-')
                      : (petition.processingStatus == 'completed' || petition.processingStatus == 'done'
                          ? DateHelper.formatDate(petition.deadlineDate, fallback: '-')
                          : '-'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.description_outlined,
                  label: 'SỐ KÝ HIỆU VĂN BẢN',
                  value: petition.documentNumber != null && petition.documentNumber!.isNotEmpty
                      ? petition.documentNumber!
                      : '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. TRÍCH YẾU VĂN BẢN
          _buildInfoItem(
            icon: Icons.subject,
            label: 'TRÍCH YẾU VĂN BẢN',
            value: petition.documentExcerpt != null && petition.documentExcerpt!.isNotEmpty
                ? petition.documentExcerpt!
                : '-',
          ),
          const SizedBox(height: 18),

          // 4. NỘI DUNG TRẢ LỜI
          _buildInfoItem(
            icon: Icons.shield_outlined,
            label: 'NỘI DUNG TRẢ LỜI',
            value: petition.responseContent != null && petition.responseContent!.isNotEmpty
                ? petition.responseContent!
                : '-',
          ),
          const SizedBox(height: 18),

          // 5. TỆP ĐÍNH KÈM TRẢ LỜI
          _buildInfoItem(
            icon: Icons.attach_file,
            label: 'TỆP ĐÍNH KÈM TRẢ LỜI',
            value: '-',
          ),
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
            Icon(
              icon,
              size: 14,
              color: isDark ? AppColors.white70 : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white70 : AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textMain,
            height: 1.3,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
