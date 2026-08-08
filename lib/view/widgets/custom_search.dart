import 'package:app_baucu_version1/untils/app_textstyles.dart';
import 'package:flutter/material.dart';

class CustomSearch extends StatelessWidget {
  const CustomSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(padding: EdgeInsets.all(16),
      child: TextField(
        style: AppTextStyle.withColor(
        AppTextStyle.buttonMedium, Theme.of(context).textTheme.bodyLarge?.color??Colors.black
        ),
        decoration: InputDecoration(
          hintText: 'search',
          hintStyle: AppTextStyle.withColor(
            AppTextStyle.buttonMedium, isDark?Colors.grey[400]!: Colors.grey[600]!,
        ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark?Colors.grey[400]!: Colors.grey[600]!,
          ),
          suffixIcon: Icon(
            Icons.tune,
            color: isDark?Colors.grey[400]!: Colors.grey[600]!,
          ),
          filled: true,
          fillColor: isDark?Colors.grey[800]!: Colors.grey[100]!,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12)

            ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark?Colors.grey[400]!: Colors.grey[600]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),

            
          ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12)

            )

        )
      ),
    );
  }
}
