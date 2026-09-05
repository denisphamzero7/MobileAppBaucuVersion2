import '../../untils/app_colors.dart';
import '../../core/utils/app_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../untils/app_textstyles.dart';
import '../widgets/custom_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  // 1. THÊM FormKey để xử lý validate
  final _formKey = GlobalKey<FormState>();

  // 2. THÊM dispose để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // 3. BỌC Column trong Form
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reset password',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email to reset your password',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? AppColors.grey[400]! : AppColors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),

                // --- EMAIL FIELD ---
                CustomTextfield(
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) => AppValidator.email(
                    value,
                    emptyMessage: 'Please enter your email',
                    customMessage: 'Invalid email format',
                  ),
                ),
                const SizedBox(height: 24),

                // --- BUTTON SEND ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // 4. SỬA LẠI logic onPressed
                    onPressed: () {
                      // Kiểm tra xem form đã hợp lệ chưa
                      if (_formKey.currentState!.validate()) {
                        // Nếu đúng thì hiện dialog
                        _showSuccessDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Send reset link',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. SỬA LẠI: Không cần truyền context vào hàm này
  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text( // Thêm const cho tối ưu
          'Check your email',
          // style: AppTextStyle.h3, // Uncomment nếu đã định nghĩa style
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'We have sent a password recover link to your email.',
          // style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Đóng dialog
              // Get.back(); // Nếu muốn quay về màn hình Login luôn thì mở dòng này
            },
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
    );
  }
}


