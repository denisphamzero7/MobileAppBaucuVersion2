import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/api_constants.dart';
import '../../../model/profile.dart';
import '../../../untils/app_colors.dart';
import '../../widgets/skeleton_loader.dart';

class UserPersonalInfoTab extends StatefulWidget {
  final ProfileData profile;
  final bool isDark;

  const UserPersonalInfoTab({
    super.key,
    required this.profile,
    required this.isDark,
  });

  @override
  State<UserPersonalInfoTab> createState() => _UserPersonalInfoTabState();
}

class _UserPersonalInfoTabState extends State<UserPersonalInfoTab> {
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();

  late final TextEditingController _phoneController;
  late final TextEditingController _cccdController;
  late final TextEditingController _addressController;
  late final TextEditingController _tempAddressController;

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    final raw = user?.rawJson ?? {};

    final phone = (raw['phone'] ?? raw['phone_number'] ?? '0337317057').toString();
    final cccd = (raw['identity_card'] ?? raw['cccd'] ?? '').toString();
    final address = (raw['address'] ?? raw['permanent_address'] ?? '').toString();
    final tempAddress = (raw['temporary_address'] ?? raw['temp_address'] ?? '').toString();

    _phoneController = TextEditingController(text: phone);
    _cccdController = TextEditingController(text: cccd);
    _addressController = TextEditingController(text: address);
    _tempAddressController = TextEditingController(text: tempAddress);

    if (raw['gender'] != null) {
      _selectedGender = raw['gender'].toString();
    }
    if (raw['birthday'] != null || raw['birth_date'] != null) {
      try {
        _selectedBirthDate = DateTime.tryParse((raw['birthday'] ?? raw['birth_date']).toString());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cccdController.dispose();
    _addressController.dispose();
    _tempAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _savePersonalInfo() async {
    setState(() {
      _isSaving = true;
    });

    // Giả lập lưu hoặc cập nhật thông tin
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _isSaving = false;
    });

    Get.snackbar(
      'Thành công',
      'Đã lưu thông tin cá nhân thành công',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_userController.isLoading.value) {
        return _buildSkeleton();
      }

      final profile = widget.profile;
      final user = _authController.currentUser.value;
      final isDark = widget.isDark;
      final initialLetter = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'G';
      final username = user?.userName.isNotEmpty == true ? user!.userName : profile.name;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==================== CARD 1: AVATAR HEADER ====================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar tròn lớn với icon camera ở góc
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBF3FE),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFD6E7FE),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: (profile.avatar != null && profile.avatar!.isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '') + profile.avatar!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  initialLetter,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              initialLetter,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2563EB),
                          border: Border.all(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Tên & phụ đề
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bấm vào biểu tượng máy ảnh để thay đổi ảnh đại diện',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.grey[400] : const Color(0xFF94A3B8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ==================== CARD 2: THÔNG TIN ĐỊNH DANH CHÍNH (ĐÃ KHÓA) ====================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFFD97706).withValues(alpha: 0.3) : const Color(0xFFFDE68A),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header khóa màu vàng cam
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'THÔNG TIN ĐỊNH DANH CHÍNH (ĐÃ KHÓA)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Họ và tên (Full width)
                _buildFieldLabel('Họ và tên:', isDark),
                const SizedBox(height: 4),
                _buildReadOnlyBox(profile.name, isDark),
                const SizedBox(height: 12),

                // Tên đăng nhập & Email (2 cột)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Tên đăng nhập:', isDark),
                          const SizedBox(height: 4),
                          _buildReadOnlyBox(username, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Email:', isDark),
                          const SizedBox(height: 4),
                          _buildReadOnlyBox(profile.email, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ==================== CARD 3: THÔNG TIN CÁ NHÂN ====================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header xanh
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'THÔNG TIN CÁ NHÂN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Giới tính & Ngày sinh (2 cột)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Giới tính:', isDark),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262626) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                hint: Text(
                                  '-- Chọn giới tính --',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                                  ),
                                ),
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                                ),
                                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                items: const [
                                  DropdownMenuItem(value: 'male', child: Text('Nam', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'female', child: Text('Nữ', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'other', child: Text('Khác', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedGender = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Ngày sinh:', isDark),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _pickBirthDate,
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF262626) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedBirthDate != null
                                        ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
                                        : '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white : AppColors.black87,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Số điện thoại & Số CMND/CCCD (2 cột)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Số điện thoại:', isDark),
                          const SizedBox(height: 4),
                          _buildTextInput(
                            controller: _phoneController,
                            hintText: 'Nhập số điện thoại',
                            isDark: isDark,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Số CMND/CCCD:', isDark),
                          const SizedBox(height: 4),
                          _buildTextInput(
                            controller: _cccdController,
                            hintText: 'Nhập số CCCD',
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Địa chỉ thường trú (Full width)
                _buildFieldLabel('Địa chỉ thường trú:', isDark),
                const SizedBox(height: 4),
                _buildTextInput(
                  controller: _addressController,
                  hintText: 'Nhập địa chỉ thường trú',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                // Địa chỉ tạm trú (Full width)
                _buildFieldLabel('Địa chỉ tạm trú:', isDark),
                const SizedBox(height: 4),
                _buildTextInput(
                  controller: _tempAddressController,
                  hintText: 'Nhập địa chỉ tạm trú',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Nút Lưu thông tin cá nhân
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePersonalInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Lưu thông tin cá nhân',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.grey[400] : const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildReadOnlyBox(String text, bool isDark) {
    return Container(
      width: double.infinity,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 12.5,
          color: isDark ? Colors.white : AppColors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.grey[500] : const Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              SkeletonLoader(child: SkeletonBox(width: 64, height: 64, radius: 32)),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(child: SkeletonBox(width: 120, height: 16, radius: 4)),
                    SizedBox(height: 6),
                    SkeletonLoader(child: SkeletonBox(width: double.infinity, height: 12, radius: 4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(child: SkeletonBox(width: 180, height: 14, radius: 4)),
              SizedBox(height: 14),
              SkeletonLoader(child: SkeletonBox(width: double.infinity, height: 38, radius: 10)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: SkeletonLoader(child: SkeletonBox(width: double.infinity, height: 38, radius: 10))),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonLoader(child: SkeletonBox(width: double.infinity, height: 38, radius: 10))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
