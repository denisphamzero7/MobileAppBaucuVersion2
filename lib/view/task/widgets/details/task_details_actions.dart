import 'package:flutter/material.dart';
import '../../../../model/task_model.dart';
import '../../../../untils/app_colors.dart';

class TaskDetailsActions extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final bool canUpdate;
  final VoidCallback onTogglePause;
  final VoidCallback onCancelTask;
  final VoidCallback onTransferTask;
  final VoidCallback onClose;

  const TaskDetailsActions({
    super.key,
    required this.task,
    required this.isDark,
    required this.canUpdate,
    required this.onTogglePause,
    required this.onCancelTask,
    required this.onTransferTask,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = task.processingStatus == 'paused';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HÀNG 1: [Tạm dừng / Tiếp tục]  [Hủy công việc]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.bgYellowLight,
                    side: const BorderSide(color: AppColors.paused, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: canUpdate ? onTogglePause : null,
                  icon: Icon(
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 18,
                    color: const Color(0xFFCA8A04),
                  ),
                  label: Text(
                    isPaused ? 'Tiếp tục' : 'Tạm dừng',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCA8A04),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.bgRedLight,
                    side: const BorderSide(color: AppColors.cancelled, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: canUpdate ? onCancelTask : null,
                  icon: const Icon(
                    Icons.block_rounded,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  label: const Text(
                    'Hủy công việc',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // HÀNG 2: [Điều chuyển]  [Đóng]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.badgeBlueBg,
                    side: const BorderSide(color: AppColors.primary, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: canUpdate ? onTransferTask : null,
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Điều chuyển',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? AppColors.white10 : AppColors.lightBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onClose,
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white70 : AppColors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
