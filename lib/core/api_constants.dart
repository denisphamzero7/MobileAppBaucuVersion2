class ApiConstants {
  // Thay đổi IP máy tính của bạn ở đây.
  // IP hiện tại của máy tính: 10.155.54.112 (dùng khi kết nối cùng mạng Wi-Fi không chặn client isolation)
  // Sử dụng 127.0.0.1 kết hợp chạy 'adb reverse tcp:8080 tcp:8080' là tối ưu nhất cho thiết bị thật cắm cáp USB
  static const String baseUrl = "https://danatec-test.theworkpc.com/api/";

  static const String login = "auth/login";
  static const String logout = "auth/logout";
  static const String register = "auth/register";
  static const String refreshToken = "auth/refresh";

  // === User Group ===
  static const String users = "users";           // Lấy danh sách users
  static const String profile = "user"; // Lấy thông tin cá nhân kèm roles/permissions
  static const String switchOrganization = "auth/switch-organization";

  // === Company Group ===
  static const String companies = "companies";

  // === News Group ===
  static const String news = "news";

  // === Voters/Scan Group ===
  static const String votersScan = "voters/scan";

  // === Document Group ===
  static const String documents = "documents";

  // === weather
  static const String weather = "weather/current";

  // === Thông báo ===
 static const String notification = "notifications/me";

  // === Công việc ===
  static const String taskAssignmentItems = "task-assignment-items";
}