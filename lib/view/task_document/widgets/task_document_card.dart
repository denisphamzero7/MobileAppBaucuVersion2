import 'package:flutter/material.dart';
import '../../../model/task_assignment_document_model.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_textstyles.dart';
import '../../../helper/date_helper.dart';
import '../../../core/widgets/app_tag.dart';

class TaskDocumentCard extends StatelessWidget {
  final TaskAssignmentDocumentModel document;
  final bool isDark;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onToggleSelect;

  const TaskDocumentCard({
    super.key,
    required this.document,
    required this.isDark,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    required this.onTap,
    required this.onLongPress,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = document.statusColor;

    final cardContent = Container(
      margin: isMultiSelectMode ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isMultiSelectMode ? (onToggleSelect ?? onTap) : onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Title
                      Text(
                        document.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.cardTitle.copyWith(
                          color: isDark ? AppColors.white : AppColors.textHeading,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Metadata Row: Type Chip + Date Chip + Task Count + Progress %
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Row(
                          children: [
                            // 1. Type chip
                            AppTag.info(
                              label: 'Văn bản',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 6),

                            // 2. Date / Document Number chip
                            AppTag.date(
                              dateText: DateHelper.formatDate(document.documentDate ?? document.documentNumber, fallback: '--/--/----'),
                              prefix: '',
                              isDark: isDark,
                            ),
                            const SizedBox(width: 6),

                            // 3. Task count chip
                            AppTag(
                              label: '${document.taskCount} CV',
                              icon: Icons.layers_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 6),

                            // 4. Progress % chip
                            AppTag.percent(
                              percent: document.completionPercent,
                              showBullet: false,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isMultiSelectMode) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelect?.call(),
                activeColor: Colors.red,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: onToggleSelect ?? onTap,
                child: cardContent,
              ),
            ),
          ],
        ),
      );
    }

    return cardContent;
  }
}
