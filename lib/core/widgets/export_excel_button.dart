import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import '../../helper/dio_helper.dart';
import '../../untils/app_colors.dart';

class ExportExcelButton extends StatefulWidget {
  final String url;
  final Map<String, dynamic>? queryParams;
  final String tooltip;
  final String fileNamePrefix;

  const ExportExcelButton({
    Key? key,
    required this.url,
    this.queryParams,
    this.tooltip = 'Xuất Excel',
    this.fileNamePrefix = 'Export',
  }) : super(key: key);

  static Future<void> downloadAndSave({
    required String url,
    Map<String, dynamic>? queryParams,
    String fileNamePrefix = 'Export',
  }) async {
    // 1. Đóng an toàn BottomSheet nếu đang mở trước khi mở dialog
    if (Get.isBottomSheetOpen == true) {
      Get.back();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    bool dialogShown = false;
    try {
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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Đang xuất dữ liệu Excel...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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

      final dio = DioHelper().dio;
      Directory dir;
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {
        dir = await getTemporaryDirectory();
      }

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final savePath = '${dir.path}/${fileNamePrefix}_$timeStamp.xlsx';

      dev.log("📥 [EXCEL EXPORT] Bắt đầu tải: $url -> $savePath | params: $queryParams", name: "ExportExcel");

      final response = await dio.download(
        url,
        savePath,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      // Đóng dialog loading
      if (dialogShown && Get.isDialogOpen == true) {
        Get.back();
        dialogShown = false;
      }

      dev.log("✅ [EXCEL EXPORT] Thành công (Status ${response.statusCode}): $savePath", name: "ExportExcel");

      if (response.statusCode == 200) {
        Get.snackbar(
          "Xuất Excel thành công",
          "Tệp đã được lưu vào thiết bị.\nBấm 'MỞ TỆP' để xem ngay.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          mainButton: TextButton(
            onPressed: () async {
              final result = await OpenFile.open(savePath);
              dev.log("📂 Mở file Excel: ${result.message}", name: "ExportExcel");
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
          "Lỗi",
          "Máy chủ trả về mã lỗi: HTTP ${response.statusCode}",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      dev.log("❌ [EXCEL EXPORT] Lỗi khi tải file: $e", name: "ExportExcel");
      if (dialogShown && Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        "Lỗi xuất file",
        "Không thể tải tệp Excel: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  State<ExportExcelButton> createState() => _ExportExcelButtonState();
}

class _ExportExcelButtonState extends State<ExportExcelButton> {
  bool _isDownloading = false;

  Future<void> _downloadAndSave() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final dio = DioHelper().dio;
      
      Directory dir;
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {
        dir = await getTemporaryDirectory();
      }

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final savePath = '${dir.path}/${widget.fileNamePrefix}_$timeStamp.xlsx';

      dev.log("📥 [EXCEL EXPORT] Bắt đầu tải widget: ${widget.url} -> $savePath", name: "ExportExcel");

      final response = await dio.download(
        widget.url,
        savePath,
        queryParameters: widget.queryParams,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Thành công", 
          "Đã xuất file thành công.\nLưu tại: $savePath",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(savePath),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text("MỞ TỆP", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
          ),
        );
      } else {
        Get.snackbar("Lỗi", "Không thể xuất dữ liệu. HTTP ${response.statusCode}", backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi tải file Excel: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
      dev.log("Export Excel Error: $e", name: "ExportExcel");
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isDownloading
        ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.file_download, size: 22),
            tooltip: widget.tooltip,
            onPressed: _downloadAndSave,
          );
  }
}
