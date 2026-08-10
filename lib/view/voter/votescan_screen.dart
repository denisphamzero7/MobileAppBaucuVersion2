import '../../untils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/voter_controller.dart';
import '../../untils/app_textstyles.dart';


class VoteScanScreen extends GetView<VoterController> {
  const VoteScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final cardColor = isDark ? AppColors.cardDark : AppColors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Khung hiển thị ảnh
                Obx(() => Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(
                      color: isDark
                          ? AppColors.grey[700]!
                          : primaryColor.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.black26
                            : AppColors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: controller.isProcessing.value
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Đang phân tích ảnh...",
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                      : (controller.imageFile.value != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(11.0),
                    child: Image.file(
                      controller.imageFile.value!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark
                              ? AppColors.grey[850]
                              : AppColors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: isDark
                                      ? AppColors.grey[600]
                                      : AppColors.grey[400],
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Lỗi hiển thị ảnh",
                                  style: AppTextStyle.withColor(
                                    AppTextStyle.bodySmall,
                                    isDark
                                        ? AppColors.grey[400]!
                                        : AppColors.grey[600]!,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 50,
                          color: isDark
                              ? AppColors.grey[600]
                              : AppColors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bấm nút "Camera" hoặc "Chọn Ảnh"',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            isDark
                                ? AppColors.grey[400]!
                                : AppColors.grey[600]!,
                          ),
                        ),
                      ],
                    ),
                  )),
                )),
                const SizedBox(height: 20),

                // Hàng nút bấm
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () => controller.pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 20),
                        label: Text(
                          'Camera',
                          style: AppTextStyle.buttonMedium,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: isDark ? 4 : 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : () =>
                            controller.pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 20),
                        label: Text(
                          'Chọn Ảnh',
                          style: AppTextStyle.buttonMedium,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: isDark ? 4 : 2,
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 24),

                // Tiêu đề kết quả
                Text(
                  'Thông tin cử tri đi bầu cử',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h3,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 12),

                // Hiển thị thông tin cử tri
                Obx(() {
                  if (controller.parsedInfo.value != null) {
                    final info = controller.parsedInfo.value!;
                    return Column(
                      children: [
                        _InfoCard(
                          label: 'Số Căn cước',
                          value: info.idNumber,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                        _InfoCard(
                          label: 'Họ tên',
                          value: info.fullName,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                        _InfoCard(
                          label: 'Ngày sinh',
                          value: info.dob,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                        _InfoCard(
                          label: 'Giới tính',
                          value: info.sex,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                        const SizedBox(height: 20),

                        // Nút Xác nhận đi bầu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.isProcessing.value
                                ? null
                                : () => controller.confirmVoteAndSave(),
                            icon: const Icon(Icons.how_to_vote_outlined, size: 20),
                            label: Text(
                              'Xác nhận đi bầu',
                              style: AppTextStyle.buttonLarge,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green.shade700,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isDark ? 4 : 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (!controller.isProcessing.value) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.grey[700]!
                              : AppColors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 40,
                              color: isDark
                                  ? AppColors.grey[600]
                                  : AppColors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chưa có thông tin cử tri',
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodyMedium,
                                isDark
                                    ? AppColors.grey[400]!
                                    : AppColors.grey[600]!,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // Nút Reset (Floating)
      floatingActionButton: Obx(() => controller.parsedInfo.value != null &&
          !controller.isProcessing.value
          ? FloatingActionButton.extended(
        onPressed: () => controller.resetScan(),
        backgroundColor: AppColors.orange.shade700,
        icon: const Icon(Icons.refresh, color: AppColors.white),
        label: Text(
          'Quét lại',
          style: AppTextStyle.withColor(
            AppTextStyle.buttonSmall,
            AppColors.white,
          ),
        ),
      )
          : const SizedBox.shrink()),
    );
  }
}

/// Widget InfoCard với Theme đồng bộ
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color cardColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.grey[700]! : AppColors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.black26 : AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppTextStyle.withColor(
              AppTextStyle.withWeight(AppTextStyle.bodyMedium, FontWeight.w600),
              Theme.of(context).primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "(Trống)" : value,
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                value.isEmpty
                    ? (isDark ? AppColors.grey[500]! : AppColors.grey[600]!)
                    : Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


