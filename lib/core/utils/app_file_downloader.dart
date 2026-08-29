import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../core/api_constants.dart';
import '../../helper/dio_helper.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 📥 [AppFileDownloader] - TIỆN ÍCH TẢI VÀ MỞ TỆP TIN TOÀN HỆ THỐNG
/// ============================================================================
class AppFileDownloader {
  AppFileDownloader._();

  /// Tải tệp từ URL về thiết bị và tự động mở bằng ứng dụng đọc tệp mặc định
  static Future<void> downloadAndOpen({
    required String fileUrl,
    String? customFileName,
    String dialogMessage = 'Đang tải tệp về thiết bị...',
  }) async {
    if (fileUrl.trim().isEmpty) {
      Get.snackbar(
        'Lỗi tệp tin',
        'Đường dẫn tệp tin không tồn tại hoặc rỗng',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // 1. Chuẩn hóa URL (Nếu là relative path thì ghép với BaseUrl)
    String finalUrl = fileUrl.trim();
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      final baseUrl = ApiConstants.baseUrl.endsWith('/')
          ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
          : ApiConstants.baseUrl;
      final cleanPath = finalUrl.startsWith('/') ? finalUrl : '/$finalUrl';
      finalUrl = '$baseUrl$cleanPath';
    }

    // 2. Chuẩn hóa tên tệp lưu trữ
    String fileName = customFileName?.trim() ?? '';
    if (fileName.isEmpty) {
      final uri = Uri.tryParse(finalUrl);
      fileName = uri?.pathSegments.isNotEmpty == true
          ? uri!.pathSegments.last
          : 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
    if (!fileName.contains('.')) {
      fileName = '$fileName.pdf';
    }

    bool dialogShown = false;
    try {
      // 3. Hiển thị Dialog Loading khi đang tải
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    dialogMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      dialogShown = true;

      // 4. Lấy thư mục lưu trữ an toàn trên thiết bị (Hỗ trợ cả Android & iOS)
      Directory dir;
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {
        dir = await getTemporaryDirectory();
      }

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final savePath = '${dir.path}/$fileName';
      dev.log("📥 [DOWNLOAD FILE] URL: $finalUrl -> Lưu tại: $savePath", name: "AppFileDownloader");

      // 5. Thực hiện tải tệp qua Dio
      final dio = DioHelper().dio;
      final response = await dio.download(
        finalUrl,
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': '*/*'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      // Đóng dialog loading
      if (dialogShown && Get.isDialogOpen == true) {
        Get.back();
        dialogShown = false;
      }

      dev.log("✅ [DOWNLOAD FILE] Thành công (Status ${response.statusCode}): $savePath", name: "AppFileDownloader");

      if (response.statusCode == 200) {
        // 6. Tự động mở tệp ngay sau khi tải xong bằng OpenFile
        final openResult = await OpenFile.open(savePath);
        dev.log("📂 [OPEN FILE] Kết quả: ${openResult.message} (${openResult.type})", name: "AppFileDownloader");

        // 7. Hiển thị Snackbar thông báo thành công kèm nút "MỞ TỆP"
        Get.snackbar(
          "Tải tệp thành công",
          "Đã lưu tệp: $fileName\nBấm 'MỞ TỆP' để xem lại bất cứ lúc nào.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          mainButton: TextButton(
            onPressed: () async {
              await OpenFile.open(savePath);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              "MỞ TỆP",
              style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        Get.snackbar(
          "Lỗi tải tệp",
          "Máy chủ phản hồi mã lỗi: HTTP ${response.statusCode}",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      dev.log("❌ [DOWNLOAD FILE] Lỗi: $e", name: "AppFileDownloader");
      if (dialogShown && Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        "Lỗi tải tệp tin",
        "Không thể tải tệp tin về máy: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
