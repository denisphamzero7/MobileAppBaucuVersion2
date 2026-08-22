import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/task_controller.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';
import 'details/task_details_actions.dart';
import 'details/task_discussion_tab.dart';
import 'details/task_document_tab.dart';
import 'details/task_info_tab.dart';
import 'details/task_report_tab.dart';

class TaskDetailsBottomSheet extends StatefulWidget {
  final TaskModel task;
  final bool isDark;
  final Color primaryColor;

  const TaskDetailsBottomSheet({
    super.key,
    required this.task,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  State<TaskDetailsBottomSheet> createState() => _TaskDetailsBottomSheetState();
}

class _TaskDetailsBottomSheetState extends State<TaskDetailsBottomSheet> {
  int _selectedTabIndex = 0; // 0: Thông tin, 1: Báo cáo, 2: Trao đổi, 3: Văn bản
  TaskModel? _currentTask;

  TaskModel get _task => _currentTask ?? widget.task;

  final List<String> _tabs = [
    'Thông tin',
    'Báo cáo',
    'Trao đổi',
    'Văn bản',
  ];

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    final taskCtrl = Get.find<TaskController>();
    final detailed = await taskCtrl.fetchTaskDetails(widget.task.id);
    if (detailed != null && mounted) {
      setState(() {
        _currentTask = detailed;
      });
    }
  }

  void _handleTogglePause(BuildContext context) {
    final taskCtrl = Get.find<TaskController>();
    final isPaused = widget.task.processingStatus == 'paused';
    final actionText = isPaused ? 'tiếp tục thực hiện' : 'tạm dừng';

    Get.defaultDialog(
      title: 'Xác nhận ${isPaused ? "tiếp tục" : "tạm dừng"}',
      middleText: 'Bạn có chắc chắn muốn $actionText công việc "${widget.task.name}"?',
      textConfirm: 'Đồng ý',
      textCancel: 'Hủy',
      confirmTextColor: AppColors.white,
      buttonColor: isPaused ? AppColors.primary : AppColors.paused,
      onConfirm: () async {
        Get.back();
        Navigator.pop(context);
        await taskCtrl.togglePauseTask(widget.task);
      },
    );
  }

  void _handleCancelTask(BuildContext context) {
    final taskCtrl = Get.find<TaskController>();
    Get.defaultDialog(
      title: 'Xác nhận hủy công việc',
      middleText: 'Bạn có chắc chắn muốn hủy công việc "${widget.task.name}"?',
      textConfirm: 'Hủy công việc',
      textCancel: 'Đóng',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.overdue,
      onConfirm: () async {
        Get.back();
        Navigator.pop(context);
        await taskCtrl.cancelTaskStatus(widget.task);
      },
    );
  }

  void _handleTransferTask(BuildContext context) {
    final taskCtrl = Get.find<TaskController>();
    final users = taskCtrl.usersList;

    if (users.isEmpty) {
      taskCtrl.fetchMetadata();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? AppColors.darkBg : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Điều chuyển công việc',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Chọn nhân sự tiếp nhận công việc này',
                style: TextStyle(fontSize: 12, color: AppColors.grey[600]),
              ),
              const Divider(height: 20),
              Expanded(
                child: Obx(() {
                  final list = taskCtrl.usersList;
                  if (list.isEmpty) {
                    return const Center(child: Text('Đang tải danh sách nhân sự...'));
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (c, idx) {
                      final u = list[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: u.email.isNotEmpty ? Text(u.email, style: const TextStyle(fontSize: 11)) : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey),
                        onTap: () async {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          await taskCtrl.reassignTask(widget.task, u.id, newUserName: u.name);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReportDialog(BuildContext context) {
    int highestPrevious = _task.completionPercent;
    if (_task.progressReports != null && _task.progressReports!.isNotEmpty) {
      for (final r in _task.progressReports!) {
        if (r.percent > highestPrevious) {
          highestPrevious = r.percent;
        }
      }
    }

    int currentPercent = highestPrevious;
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final divisions = (100 - highestPrevious) > 0 ? (100 - highestPrevious) : 1;

            return AlertDialog(
              title: const Text('Nộp báo cáo tiến độ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiến độ mới:', style: TextStyle(fontSize: 13)),
                      Text('$currentPercent%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: currentPercent.toDouble().clamp(highestPrevious.toDouble(), 100.0),
                    min: highestPrevious.toDouble(),
                    max: 100,
                    divisions: divisions > 20 ? 20 : divisions,
                    activeColor: AppColors.primary,
                    label: '$currentPercent%',
                    onChanged: (val) {
                      setDialogState(() {
                        currentPercent = val.round();
                      });
                    },
                  ),
                  if (highestPrevious > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        '* Tiến độ phải ≥ $highestPrevious% (tiến độ trước đó)',
                        style: TextStyle(fontSize: 11, color: AppColors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú / Nội dung báo cáo',
                      hintText: 'Nhập tóm tắt công việc đã hoàn thành...',
                      labelStyle: TextStyle(fontSize: 12, color: AppColors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (currentPercent < highestPrevious) {
                      Get.snackbar(
                        'Không hợp lệ',
                        'Tiến độ mới ($currentPercent%) phải lớn hơn hoặc bằng tiến độ trước ($highestPrevious%)',
                        backgroundColor: Colors.orange.shade700,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    final percent = currentPercent;
                    final note = noteCtrl.text.trim();
                    final taskCtrl = Get.find<TaskController>();
                    Navigator.pop(ctx);
                    final success = await taskCtrl.submitProgressReport(_task, percent, note);
                    if (success && mounted) {
                      await _fetchFullDetails();
                    }
                  },
                  child: const Text('Gửi báo cáo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final task = _task;
    final authCtrl = Get.find<AuthController>();
    final canUpdate = authCtrl.can('update', 'TaskAssignmentItems');
    final titleText = task.name.trim().isNotEmpty
        ? task.name.trim()
        : (task.documentName != null && task.documentName!.isNotEmpty ? task.documentName! : 'Công việc');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.white24 : AppColors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Header: Title & Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: isDark ? AppColors.white : AppColors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white10 : AppColors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark ? AppColors.white70 : AppColors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Middle Scrollable Content (Ngăn tràn màn hình)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Khối: Tiến độ thực hiện ---
                  _buildProgressBarBox(isDark, task),
                  const SizedBox(height: 14),

                  // --- Khối: Tab Selector (4 Tabs: Thông tin, Báo cáo, Trao đổi, Văn bản) ---
                  _buildTabBar(isDark),
                  const SizedBox(height: 14),

                  // --- Nội dung tương ứng của từng Tab ---
                  _buildTabContent(isDark, task),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 4. Action Buttons (Cố định ở đáy, chia 2 hàng chuẩn theo hình)
          TaskDetailsActions(
            task: task,
            isDark: isDark,
            canUpdate: canUpdate,
            onTogglePause: () => _handleTogglePause(context),
            onCancelTask: () => _handleCancelTask(context),
            onTransferTask: () => _handleTransferTask(context),
            onClose: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Khối hiển thị thanh tiến độ phần trăm
  Widget _buildProgressBarBox(bool isDark, TaskModel task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ thực hiện',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white70 : AppColors.grey[700],
                ),
              ),
              Text(
                '${task.completionPercent}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (task.completionPercent.clamp(0, 100)) / 100.0,
              backgroundColor: isDark ? AppColors.white10 : AppColors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Thanh chuyển đổi 4 Tab dạng Pill (Thông tin, Báo cáo, Trao đổi, Văn bản)
  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white10 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.cardDark : AppColors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.white70 : AppColors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Bộ điều phối nội dung theo Tab đang chọn
  Widget _buildTabContent(bool isDark, TaskModel task) {
    switch (_selectedTabIndex) {
      case 0:
        return TaskInfoTab(task: task, isDark: isDark);
      case 1:
        return TaskReportTab(
          task: task,
          isDark: isDark,
          onAddReport: () => _showAddReportDialog(context),
        );
      case 2:
        return TaskDiscussionTab(task: task, isDark: isDark);
      case 3:
        return TaskDocumentTab(task: task, isDark: isDark);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Hàm triệu gọi Task Details Bottom Sheet
void showTaskDetailsDialog(BuildContext context, TaskModel task, bool isDark, Color primaryColor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TaskDetailsBottomSheet(
      task: task,
      isDark: isDark,
      primaryColor: primaryColor,
    ),
  );
}
