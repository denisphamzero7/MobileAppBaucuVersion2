import 'package:flutter/material.dart';

/// [AppDivider] - Widget đường kẻ phân cách tái sử dụng cao cấp
/// Hỗ trợ:
/// 1. Kẻ liền chuẩn (Solid)
/// 2. Kẻ nét đứt (Dashed)
/// 3. Kẻ mờ dần Gradient (Gradient)
/// 4. Tùy chỉnh màu sắc, độ dày, độ mờ (opacity), khoảng cách đệm
class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color? color;
  final double indent;
  final double endIndent;
  final bool isDashed;
  final double dashWidth;
  final double dashGap;
  final Gradient? gradient;

  const AppDivider({
    super.key,
    this.height = 16.0,
    this.thickness = 0.8,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.isDashed = false,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.gradient,
  });

  /// Factory tạo đường kẻ mờ màu trắng (rất thích hợp cho nền tối, card Gradient như Profile Card)
  factory AppDivider.white({
    Key? key,
    double height = 20.0,
    double thickness = 0.8,
    double opacity = 0.2,
    double indent = 0.0,
    double endIndent = 0.0,
  }) {
    return AppDivider(
      key: key,
      height: height,
      thickness: thickness,
      color: Colors.white.withValues(alpha: opacity),
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// Factory tạo đường kẻ mờ nhẹ màu xám (cho các Card trắng, danh sách items)
  factory AppDivider.light({
    Key? key,
    double height = 16.0,
    double thickness = 0.6,
    double indent = 0.0,
    double endIndent = 0.0,
  }) {
    return AppDivider(
      key: key,
      height: height,
      thickness: thickness,
      color: Colors.black.withValues(alpha: 0.06),
      indent: indent,
      endIndent: endIndent,
    );
  }

  /// Factory tạo đường kẻ nét đứt (Dashed)
  factory AppDivider.dashed({
    Key? key,
    double height = 16.0,
    double thickness = 1.0,
    Color? color,
    double dashWidth = 5.0,
    double dashGap = 3.0,
    double indent = 0.0,
    double endIndent = 0.0,
  }) {
    return AppDivider(
      key: key,
      height: height,
      thickness: thickness,
      color: color,
      isDashed: true,
      dashWidth: dashWidth,
      dashGap: dashGap,
      indent: indent,
      endIndent: endIndent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).dividerColor.withValues(alpha: 0.15);

    if (isDashed) {
      return SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: endIndent),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.constrainWidth();
              final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: thickness,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: effectiveColor),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      );
    }

    if (gradient != null) {
      return Container(
        height: height,
        padding: EdgeInsets.only(left: indent, right: endIndent),
        alignment: Alignment.center,
        child: Container(
          height: thickness,
          decoration: BoxDecoration(gradient: gradient),
        ),
      );
    }

    return Divider(
      height: height,
      thickness: thickness,
      color: effectiveColor,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
