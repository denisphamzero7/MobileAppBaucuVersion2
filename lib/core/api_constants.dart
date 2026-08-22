class ApiConstants {
  // Thay đổi IP máy tính của bạn ở đây.
  // IP hiện tại của máy tính: 10.155.54.112 (dùng khi kết nối cùng mạng Wi-Fi không chặn client isolation)
  // Sử dụng 127.0.0.1 kết hợp chạy 'adb reverse tcp:8080 tcp:8080' là tối ưu nhất cho thiết bị thật cắm cáp USB
  // Sử dụng trực tiếp IP 192.168.168.6 vì máy ảo Android không đọc được file hosts của Windows
  static const String baseUrl = "https://192.168.168.6/api/";

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
  static const String taskImport = "task-assignment-items/import";
  static const String taskExport = "task-assignment-items/export";
  static const String taskBulkDelete = "task-assignment-items/bulk-delete";
  static const String taskStats = "task-assignment-items/stats";
  static const String taskStatsByDepartment = "task-assignment-items/stats-by-department";
  static const String taskStatsByItemType = "task-assignment-items/stats-by-item-type";
  static const String taskAssignmentItemTypes = "task-assignment-item-types";
  static const String taskAssignmentDepartments = "task-assignment-departments";
  static const String taskAssignmentPetitions = "task-assignment-petitions";
  static const String taskAssignmentPetitionsDepartments = "task-assignment-petitions/available-departments";
  static const String taskAssignmentPetitionsStats = "task-assignment-petitions/stats";

  // === Báo cáo công việc ===
  static const String taskAssignmentItemReports = "task-assignment-item-reports";

  // === Van ban công việc ===
  static const String taskAssignmentDocuments = "task-assignment-documents";
}
