import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../../helper/dio_helper.dart';

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
      
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
        dir ??= await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final savePath = '${dir.path}/${widget.fileNamePrefix}_$timeStamp.xlsx';

      final response = await dio.download(
        widget.url,
        savePath,
        queryParameters: widget.queryParams,
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Thành công", 
          "Đã xuất file thành công.\nLưu tại: $savePath",
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(savePath),
            child: const Text("MỞ FILE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        );
      } else {
        Get.snackbar("Lỗi", "Không thể xuất dữ liệu. HTTP ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi tải file Excel");
      print("Export Excel Error: $e");
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
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
        : IconButton(
            icon: const Icon(Icons.file_download, size: 22),
            tooltip: widget.tooltip,
            onPressed: _downloadAndSave,
          );
  }
}
