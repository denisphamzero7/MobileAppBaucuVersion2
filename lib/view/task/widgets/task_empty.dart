import 'package:flutter/material.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';

class TaskEmpty extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final double topPadding;

  const TaskEmpty({
    super.key,
    this.message,
    this.icon,
    this.topPadding = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.assignment_turned_in_outlined,
              size: 48,
              color: isDark ? AppColors.grey[600] : AppColors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              message ?? AppStrings.noTasksFound,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.grey[400] : AppColors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}