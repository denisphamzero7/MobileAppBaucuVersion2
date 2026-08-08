import 'package:app_baucu_version1/controllers/notification_controller.dart';
import 'package:app_baucu_version1/model/notification.dart';
import 'package:app_baucu_version1/untils/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Tự động load lại danh sách khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Thông báo",
          style: AppTextStyle.h3.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    Get.snackbar("Thành công", "Đã đánh dấu tất cả là đã đọc");
                  },
                  child: Text(
                    "Đọc tất cả",
                    style: AppTextStyle.buttonSmall.copyWith(color: primaryColor),
                  ),
                )
              : const SizedBox.shrink())
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return _buildNotificationItem(context, item, isDark);
            },
          ),
        );
      }),
    );
  }

  // --- WIDGET CON: ITEM THÔNG BÁO ---
  Widget _buildNotificationItem(BuildContext context, NotificationModel item, bool isDark) {
    final bool isRead = item.isRead;
    final String type = item.type;
    final DateTime time = item.createdAt;

    // Màu nền: Chưa đọc thì sáng hơn/đậm hơn để nổi bật
    final bgColor = isDark
        ? (isRead ? Colors.grey[900] : Colors.grey[800])
        : (isRead ? Colors.white : Colors.blue[50]);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        controller.notifications.remove(item);
      },
      child: GestureDetector(
        onTap: () {
          // Xử lý khi bấm vào thông báo
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isRead) // Chỉ đổ bóng nếu chưa đọc
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
              border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1
              )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon theo loại
              _buildTypeIcon(type),

              const SizedBox(width: 16),

              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyle.bodyMedium.copyWith(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, // Chưa đọc thì đậm hơn
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.content,
                      style: AppTextStyle.bodySmall.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.4
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(time),
                      style: AppTextStyle.labelMedium.copyWith(
                          color: Colors.grey,
                          fontSize: 12
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER: ICON THEO LOẠI THÔNG BÁO ---
  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'VOTE_SUCCESS':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'VOTE_WARNING':
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case 'SYSTEM':
        icon = Icons.info_outline;
        color = Colors.blue;
        break;
      case 'UPDATE_VOTER':
        icon = Icons.person_search_outlined;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications_none;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  // --- HELPER: FORMAT THỜI GIAN ---
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return "Vừa xong";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} phút trước";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} giờ trước";
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(time);
    }
  }

  // --- WIDGET: EMPTY STATE ---
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Không có thông báo nào",
            style: AppTextStyle.h3.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Các thông báo mới sẽ xuất hiện tại đây",
            style: AppTextStyle.bodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}