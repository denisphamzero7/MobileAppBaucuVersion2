import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import '../../helper/dio_helper.dart';

class ImportExcelButton extends StatefulWidget {
  final String uploadUrl;
  final String tooltip;
  final VoidCallback? onSuccess;
  final Widget? icon;

  const ImportExcelButton({
    Key? key,
    required this.uploadUrl,
    this.tooltip = 'Nhập Excel',
    this.onSuccess,
    this.icon,
  }) : super(key: key);

  @override
  State<ImportExcelButton> createState() => _ImportExcelButtonState();
}

class _ImportExcelButtonState extends State<ImportExcelButton> {
  bool _isUploading = false;

  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        _uploadFile(file);
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể chọn file: $e");
    }
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = file.path.split('/').last;
      
      // Dùng DioHelper() để tự động đính kèm token và base url
      final dio = DioHelper().dio;
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dio.post(
        widget.uploadUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        Get.snackbar("Thành công", "Đã nhập dữ liệu thành công!");
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
      } else {
        Get.snackbar("Lỗi", "Không thể nhập dữ liệu. HTTP ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi tải file lên");
      print("Import Excel Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isUploading
        ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
        : IconButton(
            icon: widget.icon ?? const Icon(Icons.upload_file, size: 22),
            tooltip: widget.tooltip,
            onPressed: _pickAndUploadFile,
          );
  }
}
