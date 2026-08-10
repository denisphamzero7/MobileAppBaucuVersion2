import '../../untils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class SkeletonLoader extends StatelessWidget {
  final Widget child;
  
  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
        baseColor: isDark? AppColors.grey[800]!: AppColors.grey[300]!,
        highlightColor: isDark?AppColors.grey[700]!:AppColors.grey[100]!,
        child: child
    );

  }

}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius =8
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(radius)
      ),
    );
  }
}




