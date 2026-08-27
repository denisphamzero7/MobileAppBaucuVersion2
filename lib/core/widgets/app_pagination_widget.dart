import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// Widget phân trang giao diện hiện đại dùng chung cho toàn bộ ứng dụng:
/// - Công việc đang giao / Công việc được giao
/// - Quản lý đơn thư
/// - Quản lý cử tri / người dùng
class AppPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final bool isLoading;
  final EdgeInsetsGeometry padding;

  const AppPaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.itemsPerPage = 10,
    required this.onPageChanged,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  void _showPagePicker(BuildContext context, int safeTotalPages) {
    if (safeTotalPages <= 1) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo nhỏ trên đầu modal
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white30 : AppColors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chọn trang (Tổng $safeTotalPages trang)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.white : AppColors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(safeTotalPages, (index) {
                      final pageNumber = index + 1;
                      final isSelected = pageNumber == currentPage;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          if (pageNumber != currentPage) {
                            onPageChanged(pageNumber);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.cardItemDark : AppColors.lightBg),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.white10 : AppColors.black12),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            '$pageNumber',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.white : AppColors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int safeTotalPages = totalPages > 0 ? totalPages : 1;
    final int safeCurrentPage = currentPage.clamp(1, safeTotalPages);

    final bool canPrev = safeCurrentPage > 1 && !isLoading;
    final bool canNext = safeCurrentPage < safeTotalPages && !isLoading;

    final int fromItem = totalItems == 0 ? 0 : ((safeCurrentPage - 1) * itemsPerPage) + 1;
    int toItem = safeCurrentPage * itemsPerPage;
    if (toItem > totalItems) toItem = totalItems;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nút Trước
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canPrev ? () => onPageChanged(safeCurrentPage - 1) : null,
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: canPrev
                      ? (isDark ? AppColors.white10 : AppColors.badgeBlueBg)
                      : (isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.lightBg),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canPrev
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 16,
                      color: canPrev
                          ? AppColors.primary
                          : (isDark ? AppColors.white30 : AppColors.grey[400]),
                    ),
                    const SizedBox(width: 1),
                    Text(
                      'Trước',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: canPrev ? FontWeight.w700 : FontWeight.w500,
                        color: canPrev
                            ? AppColors.primary
                            : (isDark ? AppColors.white30 : AppColors.grey[400]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Thông tin trang & Số lượng mục ở giữa (Thanh Chip tinh tế)
          Expanded(
            child: InkWell(
              onTap: isLoading ? null : () => _showPagePicker(context, safeTotalPages),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.white70 : AppColors.black87,
                                ),
                                children: [
                                  const TextSpan(text: 'Trang '),
                                  TextSpan(
                                    text: '$safeCurrentPage',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / $safeTotalPages',
                                    style: TextStyle(
                                      color: isDark ? AppColors.white70 : AppColors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (safeTotalPages > 1) ...[
                              const SizedBox(width: 2),
                              Icon(
                                Icons.unfold_more_rounded,
                                size: 13,
                                color: isDark ? AppColors.white30 : AppColors.grey[600],
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3.5),
                        Flexible(
                          child: Text(
                            totalItems > 0
                                ? 'Hiển thị $fromItem – $toItem của $totalItems mục'
                                : 'Không có dữ liệu',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.white30 : AppColors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nút Sau
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canNext ? () => onPageChanged(safeCurrentPage + 1) : null,
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: canNext
                      ? (isDark ? AppColors.white10 : AppColors.badgeBlueBg)
                      : (isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.lightBg),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canNext
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sau',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: canNext ? FontWeight.w700 : FontWeight.w500,
                        color: canNext
                            ? AppColors.primary
                            : (isDark ? AppColors.white30 : AppColors.grey[400]),
                      ),
                    ),
                    const SizedBox(width: 1),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: canNext
                          ? AppColors.primary
                          : (isDark ? AppColors.white30 : AppColors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
