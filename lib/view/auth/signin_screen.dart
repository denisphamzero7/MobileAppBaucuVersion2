import '../../untils/app_colors.dart';
import 'package:app_baucu_version1/controllers/auth_controller.dart';
import 'package:app_baucu_version1/untils/app_textstyles.dart';
import 'package:app_baucu_version1/view/auth/forgot_password.dart';
import 'package:app_baucu_version1/view/auth/signup_screen.dart';
import 'package:app_baucu_version1/view/widgets/custom_textfield.dart';
import '../../model/auth_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/organization_selection_dialog.dart';
import 'package:get/get.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final AuthController _authController = Get.put(AuthController());

  // Đổi tên biến cho rõ nghĩa
  final TextEditingController _usernameController = TextEditingController(text: 'admin@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'quandcore**11');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Danang city',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue voter',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? AppColors.grey[400]! : AppColors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),

                // --- USERNAME/EMAIL FIELD ---
                CustomTextfield(
                  label: 'Email or Username', // Rõ ràng hơn cho user
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or username';
                    }
                    // Bỏ validation email vì có thể nhập username
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --- PASSWORD FIELD ---
                CustomTextfield(
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgotPassword()),
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),

                // Sign in button
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() {
                    if (_authController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ElevatedButton(
                      onPressed: _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Sign in',
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          AppColors.white,
                        ),
                      ),
                    );
                  }),
                ),

                // Sign up button
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        isDark ? AppColors.grey[400]! : AppColors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const SignupScreen()),
                      child: Text(
                        'Sign up',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

    void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      final loginData = await _authController.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (loginData != null) {
        _showOrganizationSelectionDialog(loginData);
      }
    }
  }

  void _showOrganizationSelectionDialog(LoginData data) {
    Get.dialog(
      OrganizationSelectionDialog(
        organizations: data.availableOrganizations,
        isCancellable: false,
        onSelect: (orgId) async {
          final success = await _authController.switchOrganizationAfterLogin(orgId, data);
          if (success) {
            Get.back();
          }
        },
        onCancel: () {
          GetStorage().remove('accessToken');
          Get.back();
          Get.snackbar("Đăng nhập thất bại", "Bạn chưa chọn tổ chức");
        },
      ),
      barrierDismissible: false,
    );
  }
}
