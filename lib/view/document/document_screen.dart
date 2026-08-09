import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';
import '../../untils/app_colors.dart';
import '../../service/petition_service.dart';

class PetitionModel {
  final String status; // 'new', 'processing', 'completed', 'paused', 'cancelled'
  final String date;
  final String title;
  final String petitioner;
  final String content;
  final String department;
  final String deadline;

  PetitionModel({
    required this.status,
    required this.date,
    required this.title,
    required this.petitioner,
    required this.content,
    required this.department,
    required this.deadline,
  });
}

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString searchText = ''.obs;
  
  final PetitionService _petitionService = PetitionService();
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final Rxn<DepartmentModel> selectedDepartment = Rxn<DepartmentModel>();

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final response = await _petitionService.getAvailableDepartments();
    if (response != null && response.data != null) {
      departments.assignAll(response.data!);
    }
  }

  final List<PetitionModel> petitions = [
    PetitionModel(
      status: 'new',
      date: '30/07/2026',
      title: 'Đơn thư & Kiến nghị',
      petitioner: '21321nęd',
      content: '1231221',
      department: 'Phòng Thông tin - Tổng hợp',
      deadline: '31/07/2026',
    ),
    PetitionModel(
      status: 'processing',
      date: '25/07/2026',
      title: 'Kiến nghị lấn chiếm vỉa hè đường Lê Lợi',
      petitioner: 'Trần Văn Hoàng',
      content: 'Đề nghị lực lượng chức năng kiểm tra và xử lý tình trạng đỗ xe và lấn chiếm lòng lề đường kinh doanh buôn bán gây ùn tắc giao thông.',
      department: 'Đội Quản lý đô thị',
      deadline: '05/08/2026',
    ),
    PetitionModel(
      status: 'completed',
      date: '20/07/2026',
      title: 'Khiếu nại về vệ sinh môi trường khu phố 4',
      petitioner: 'Nguyễn Thị Minh',
      content: 'Bãi tập kết rác thải tự phát bốc mùi hôi thối ảnh hưởng nghiêm trọng đến đời sống sinh hoạt của toàn bộ các hộ dân xung quanh.',
      department: 'Phòng Tài nguyên - Môi trường',
      deadline: '28/07/2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () {
            Get.find<NavigationController>().changeIndex(0);
          },
        ),
        title: const Text(
          'Đơn thư & Kiến nghị',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: Obx(() {
          // 1. Calculate statistics
          final totalCount = petitions.length;
          final newCount = petitions.where((p) => p.status == 'new').length;
          final processingCount = petitions.where((p) => p.status == 'processing').length;
          final completedCount = petitions.where((p) => p.status == 'completed').length;
          final pausedCount = petitions.where((p) => p.status == 'paused').length;
          final cancelledCount = petitions.where((p) => p.status == 'cancelled').length;

          // 2. Apply filters
          var filteredPetitions = List<PetitionModel>.from(petitions);

          if (searchText.value.isNotEmpty) {
            final query = searchText.value.toLowerCase();
            filteredPetitions = filteredPetitions.where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.petitioner.toLowerCase().contains(query) ||
              p.content.toLowerCase().contains(query) ||
              p.department.toLowerCase().contains(query)
            ).toList();
          }

          if (selectedStatusFilter.value != 'all') {
            filteredPetitions = filteredPetitions.where((p) => p.status == selectedStatusFilter.value).toList();
          }
          
          if (selectedDepartment.value != null) {
            filteredPetitions = filteredPetitions.where((p) => p.department == selectedDepartment.value!.name).toList();
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. SEARCH BAR & RESET FILTER BUTTON
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          onChanged: (val) => searchText.value = val,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm theo tên, CCCD, SĐT, email, nội dung',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_alt_outlined, size: 18, color: Colors.grey),
                        onPressed: () {
                          selectedStatusFilter.value = 'all';
                          searchText.value = '';
                          selectedDepartment.value = null;
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),


                // B. STATISTICS GRID
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.7,
                  children: [
                    _buildStatCard(
                      label: 'Tổng đơn thư',
                      count: totalCount,
                      color: AppColors.primary,
                      isSelected: selectedStatusFilter.value == 'all',
                      onTap: () => selectedStatusFilter.value = 'all',
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      label: 'Mới tiếp nhận',
                      count: newCount,
                      color: Colors.grey[700]!,
                      isSelected: selectedStatusFilter.value == 'new',
                      onTap: () => selectedStatusFilter.value = 'new',
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      label: 'Đang xử lý',
                      count: processingCount,
                      color: AppColors.primary,
                      isSelected: selectedStatusFilter.value == 'processing',
                      onTap: () => selectedStatusFilter.value = 'processing',
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      label: 'Đã hoàn thành',
                      count: completedCount,
                      color: AppColors.done,
                      isSelected: selectedStatusFilter.value == 'completed',
                      onTap: () => selectedStatusFilter.value = 'completed',
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      label: 'Tạm dừng',
                      count: pausedCount,
                      color: AppColors.paused,
                      isSelected: selectedStatusFilter.value == 'paused',
                      onTap: () => selectedStatusFilter.value = 'paused',
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      label: 'Đã hủy',
                      count: cancelledCount,
                      color: AppColors.overdue,
                      isSelected: selectedStatusFilter.value == 'cancelled',
                      onTap: () => selectedStatusFilter.value = 'cancelled',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // C. LIST OF PETITIONS
                if (filteredPetitions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Không có đơn thư nào phù hợp',
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPetitions.length,
                    itemBuilder: (context, index) {
                      final petition = filteredPetitions[index];
                      return _buildPetitionCard(context, petition, isDark);
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    Color cardBg;
    Color textColor;

    if (label == 'Tổng đơn thư') {
      cardBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F3FF);
      textColor = const Color(0xFF8B5CF6);
    } else if (label == 'Mới tiếp nhận') {
      cardBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6);
      textColor = const Color(0xFF4B5563);
    } else if (label == 'Đang xử lý') {
      cardBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F9FF);
      textColor = const Color(0xFF0EA5E9);
    } else if (label == 'Đã hoàn thành') {
      cardBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFECFDF5);
      textColor = const Color(0xFF10B981);
    } else if (label == 'Tạm dừng') {
      cardBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFBEB);
      textColor = const Color(0xFFF59E0B);
    } else if (label == 'Đã hủy') {
      cardBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFEF2F2);
      textColor = const Color(0xFFEF4444);
    } else {
      cardBg = isDark ? const Color(0xFF2D2D2D) : Colors.white;
      textColor = color;
    }

    Color borderCol = isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderCol,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : textColor.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetitionCard(BuildContext context, PetitionModel petition, bool isDark) {
    // Determine status badge properties
    String badgeText = 'Mới tiếp nhận';
    Color badgeColor = Colors.grey[600]!;
    Color badgeBg = isDark ? Colors.white10 : const Color(0xFFF3F4F6);

    if (petition.status == 'processing') {
      badgeText = 'Đang xử lý';
      badgeColor = AppColors.primary;
      badgeBg = const Color(0xFFEFF6FF);
    } else if (petition.status == 'completed') {
      badgeText = 'Đã hoàn thành';
      badgeColor = AppColors.done;
      badgeBg = const Color(0xFFECFDF5);
    } else if (petition.status == 'paused') {
      badgeText = 'Tạm dừng';
      badgeColor = AppColors.paused;
      badgeBg = const Color(0xFFFFFBEB);
    } else if (petition.status == 'cancelled') {
      badgeText = 'Đã hủy';
      badgeColor = AppColors.overdue;
      badgeBg = const Color(0xFFFEE2E2);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status badge & date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                petition.date,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Title
          Text(
            petition.title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Petitioner info
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Người nộp: ${petition.petitioner}',
                style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 4: Body content text
          Text(
            petition.content,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 10),

          // Row 5: Department & Deadline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.apartment, size: 14, color: Colors.blue[600]),
                  const SizedBox(width: 6),
                  Text(
                    petition.department,
                    style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                'Hạn: ${petition.deadline}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
