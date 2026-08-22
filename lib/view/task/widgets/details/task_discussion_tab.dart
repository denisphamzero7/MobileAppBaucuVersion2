import 'package:flutter/material.dart';
import '../../../../model/task_model.dart';
import '../../../../untils/app_colors.dart';

class TaskDiscussionTab extends StatefulWidget {
  final TaskModel task;
  final bool isDark;

  const TaskDiscussionTab({
    super.key,
    required this.task,
    required this.isDark,
  });

  @override
  State<TaskDiscussionTab> createState() => _TaskDiscussionTabState();
}

class _TaskDiscussionTabState extends State<TaskDiscussionTab> {
  final TextEditingController _commentController = TextEditingController();
  final List<TaskDiscussionNote> _localComments = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _localComments.add(TaskDiscussionNote(
          id: DateTime.now().millisecondsSinceEpoch,
          authorName: 'Tôi',
          content: text,
          createdAt: 'Vừa xong',
        ));
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final allComments = [
      ...?widget.task.discussions,
      ..._localComments,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          if (allComments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có trao đổi nào cho công việc này',
                    style: TextStyle(fontSize: 12, color: AppColors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allComments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final c = allComments[idx];
                final initial = c.authorName.isNotEmpty ? c.authorName[0].toUpperCase() : 'U';
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        initial,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.authorName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.white : AppColors.black87,
                                  ),
                                ),
                                if (c.createdAt.isNotEmpty)
                                  Text(
                                    c.createdAt,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.white70 : AppColors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.content,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.white70 : AppColors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Nhập nội dung trao đổi...',
                      hintStyle: TextStyle(fontSize: 12, color: AppColors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _handleSend,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
