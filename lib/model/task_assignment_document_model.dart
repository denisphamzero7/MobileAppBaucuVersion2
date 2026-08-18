class TaskAssignmentDocument {
  final int id;
  final String name;
  final String? code;
  final String? documentNumber;

  TaskAssignmentDocument({
    required this.id,
    required this.name,
    this.code,
    this.documentNumber,
  });

  factory TaskAssignmentDocument.fromJson(Map<String, dynamic> json) {
    final title = json['name'] ?? json['title'] ?? json['document_number'] ?? json['subject'];
    return TaskAssignmentDocument(
      id: json['id'] as int? ?? 0,
      name: title?.toString() ?? 'Văn bản #${json['id']}',
      code: json['code']?.toString(),
      documentNumber: json['document_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "document_number": documentNumber,
  };
}
