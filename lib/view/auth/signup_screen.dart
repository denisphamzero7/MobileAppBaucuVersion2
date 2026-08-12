import '../../untils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../untils/app_textstyles.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Khai báo các Controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // 1. THÊM CONTROLLER CHO CONFIRM PASSWORD
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    // 2. DISPOSE CONTROLLER MỚI
    _confirmPasswordController.dispose();
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
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Signup to get started',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? AppColors.grey[400]! : AppColors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 30),

                // --- 1. USER NAME ---
                CustomTextfield(
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 2. EMAIL ---
                CustomTextfield(
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 3. PHONE ---
                CustomTextfield(
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 4. PASSWORD ---
                CustomTextfield(
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter password';
                    if (value.length < 6) return 'Password must be at least 6 chars';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --- 5. CONFIRM PASSWORD (MỚI THÊM) ---
                CustomTextfield(
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_clock_outlined, // Icon khác một chút cho đẹp
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    // LOGIC KIỂM TRA TRÙNG KHỚP
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // --- SIGN UP BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        AppColors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- FOOTER LINK ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        isDark ? AppColors.grey[400]! : AppColors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Sign In',
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

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final AuthController authController = Get.find<AuthController>();
        final success = await authController.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (success) {
          Get.back();
        }
      } catch (e) {
        print("Chưa tìm thấy AuthController hoặc lỗi đăng ký: $e");
      }
    }
  }
}


