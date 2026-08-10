import '../untils/app_colors.dart';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';


import '../helper/scan_voter_request.dart';
import '../service/database_helper.dart';
import '../service/voter_service.dart';
import 'auth_controller.dart';

class VoterController extends GetxController {
  final VoterService _voterService = VoterService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
  TextRecognizer(script: TextRecognitionScript.latin);

  // Lấy AuthController để kiểm tra trạng thái đăng nhập
  final AuthController _authController = Get.find<AuthController>();

  // --- State Management ---
  final RxBool isProcessing = false.obs;
  final Rx<File?> imageFile = Rx<File?>(null);
  final RxString extractedText = "Chưa có dữ liệu".obs;
  final Rx<CitizenInfo?> parsedInfo = Rx<CitizenInfo?>(null);

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }



  //
  Future<void> pickImage(ImageSource source) async {


    if (isProcessing.value) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile == null) {
        log("Người dùng hủy chọn ảnh");
        return;
      }

      await _startProcessing(pickedFile.path);
    } catch (e) {
      log("Lỗi khi chọn ảnh: $e");
      Get.snackbar(
        "Lỗi",
        "Lỗi khi chọn ảnh: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 2. Hàm bắt đầu xử lý ảnh
  Future<void> _startProcessing(String imagePath) async {

    final file = File(imagePath);

    try {
      final int fileLength = await file.length();

      if (fileLength == 0) {
        log("Lỗi: Tệp ảnh rỗng (0 byte)");
        Get.snackbar(
          "Lỗi",
          "Tệp ảnh được chọn bị hỏng hoặc rỗng.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Reset state
      imageFile.value = file;
      extractedText.value = "Đang xử lý...";
      parsedInfo.value = null;
      isProcessing.value = true;

      await _processImage(imagePath);
    } catch (e) {
      log("Lỗi khi kiểm tra độ dài tệp: $e");
      Get.snackbar(
        "Lỗi",
        "Không thể truy cập tệp ảnh.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 3. Hàm xử lý ảnh bằng ML Kit
  Future<void> _processImage(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);

    try {
      final RecognizedText recognizedText =
      await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;

      // Phân tích dữ liệu
      CitizenInfo parsedData = _parseCCCD(fullText);

      extractedText.value = fullText;
      parsedInfo.value = parsedData;
    } catch (e) {
      log("Lỗi khi xử lý ảnh hoặc phân tích dữ liệu: $e");

      String userMessage = "Lỗi không xác định khi xử lý ảnh.";
      if (e is Exception) {
        // Bắt lỗi khi phân tích dữ liệu thất bại
        userMessage = "${e.toString().replaceAll('Exception: ', '')} Vui lòng quét lại ảnh rõ nét hơn.";
      } else {
        userMessage = "Không thể xử lý ảnh. Vui lòng thử lại.";
      }

      extractedText.value = "Lỗi phân tích: $userMessage";
      parsedInfo.value = null;
      Get.snackbar(
        "Lỗi Dữ liệu", // Đã đổi tiêu đề để hiển thị lỗi phân tích cụ thể hơn
        userMessage, // Hiển thị thông báo lỗi chi tiết hơn
        backgroundColor: AppColors.orange.shade700,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // 4. Hàm phân tích CCCD (ĐÃ SỬA ĐỔI PHẦN BẮT LỖI)
  CitizenInfo _parseCCCD(String rawText) {
    print("--- Dữ liệu thô từ ML Kit (Quét Thẻ Cử Tri) ---");
    print(rawText);
    print("-----------------------------");

    const String notFound = "Không tìm thấy"; // Đặt hằng số cho giá trị mặc định
    const String basePattern = r"\s*(?:\(\d\))?\s*:?\s*(?:[\s(),)]*)([^\n]*)";
    const String dobPattern = r"(\d{1,2}[\/\s-]\d{1,2}[\/\s-]\d{4})";

    String fullName = _findValue(rawText, r"H[ọo] và tên" + basePattern);
    String dob = _findValue(rawText, dobPattern);

    if (dob != notFound) {
      dob = dob
          .replaceAll(' ', '')
          .replaceAll('S', '8')
          .replaceAll('O', '0')
          .replaceAll('-', '/')
          .trim();
    }

    String sex = _findValue(rawText, r"Gi[ớó]i t[iíỉ]nh" + basePattern);
    if (sex != notFound) {
      sex = sex.trim();
    }

    String idNumber = _findValue(rawText,
        r"(?:S0|Số|So|S6I|SáI)[\s\S]*?(?:No)?:?[\s\S]*?(\d{8}[\s-]?\d{4})");
    if (idNumber == notFound) {
      idNumber = _findValue(rawText, r"(\d{8}[\s-]?\d{4})");
    }
    if (idNumber != notFound) {
      idNumber = idNumber.replaceAll(' ', '').replaceAll('-', '');
    }

    // --- LOGIC BẮT LỖI MỚI ---
    if (idNumber.trim().isEmpty || idNumber == notFound) {
      throw Exception("Không tìm thấy Số CCCD/CMND.");
    }
    if (fullName.trim().isEmpty || fullName == notFound) {
      throw Exception("Không tìm thấy Họ và tên.");
    }
    if (dob.trim().isEmpty || dob == notFound) {
      throw Exception("Không tìm thấy Ngày tháng năm sinh.");
    }
    // Đảm bảo chỉ trả về đối tượng khi đã vượt qua tất cả các kiểm tra bắt buộc

    return CitizenInfo(
      idNumber: idNumber.trim(),
      fullName: fullName.trim(),
      dob: dob.trim(),
      sex: sex.trim(),
      placeOfResidence: "",
      nationality: 'Không quét',
      placeOfOrigin: 'Không quét',
      dateOfExpiry: 'Không quét',
      personalIdentification: 'Không quét',
      dateOfIssue: 'Không quét',
      placeOfIssue: 'Không quét',
    );
  }

  // 5. Hàm trợ giúp dùng RegEx
  String _findValue(String text, String pattern) {
    final match = RegExp(
      pattern,
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    ).firstMatch(text);

    return match?.group(1)?.trim() ?? "Không tìm thấy";
  }

  // 6. Hàm xác nhận đi bầu (Gửi API và lưu SQLite)
  Future<void> confirmVoteAndSave() async {
    if (parsedInfo.value == null || isProcessing.value) {
      Get.snackbar(
        "Cảnh báo",
        "Chưa có thông tin cử tri để xác nhận.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String cccdToConfirm = parsedInfo.value!.idNumber;
    final requestData = ScanVoterRequest(cccd: cccdToConfirm);

    isProcessing.value = true;

    try {
      // --- 1. KIỂM TRA & CHÈN VÀO SQLITE CỤC BỘ ---
      final existingCitizen = await _dbHelper.getCitizenByCCCD(cccdToConfirm);

      if (existingCitizen == null) {
        await _dbHelper.insertCitizen(parsedInfo.value!);
        log('Đã chèn bản ghi mới vào SQLite: $cccdToConfirm');
      } else {
        log('Bản ghi đã tồn tại trong SQLite. Bỏ qua chèn.');
      }

      // --- 2. GỌI API XÁC NHẬN ĐI BẦU ---
      final response = await _voterService.scanVoter(requestData);

      // --- 3. XỬ LÝ PHẢN HỒI API ---
      if (response != null && response.statusCode == 201) {
        // --- 4. CẬP NHẬT TRẠNG THÁI ĐÃ BẦU ---
        await _dbHelper.markVoterAsVoted(cccdToConfirm);

        Get.snackbar(
          "Thành công",
          response.message,
          backgroundColor: Get.theme.primaryColor,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Reset trạng thái
        _resetState();
      } else {
        Get.snackbar(
          "Cảnh báo",
          response?.message ?? 'Lỗi xác nhận cử tri không xác định.',
          backgroundColor: AppColors.orange.shade700,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log("Lỗi khi gọi API xác nhận: $e");
      String errorMessage = 'Lỗi kết nối hoặc thông tin cử tri không hợp lệ.';

      if (e is DioException && e.response != null) {
        // Kiểm tra mã lỗi cụ thể từ server
        if (e.response!.statusCode == 404) {
          errorMessage = 'Cử tri không tồn tại trong hệ thống. Không thể xác nhận đi bầu.';
        } else {
          // Lấy thông báo lỗi từ server (ví dụ: body 'message')
          errorMessage = e.response!.data['message'] ??
              'Lỗi từ máy chủ: ${e.response!.statusCode}';
        }
      }

      Get.snackbar(
        "Lỗi",
        errorMessage,
        backgroundColor: AppColors.red.shade700,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // 7. Hàm reset state
  void _resetState() {
    parsedInfo.value = null;
    imageFile.value = null;
    extractedText.value = "Chưa có dữ liệu";
  }

  // 8. Hàm reset thủ công (có thể gọi từ UI)
  void resetScan() {
    _resetState();
  }
}


