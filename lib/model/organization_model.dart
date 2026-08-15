class Organization {
  final int id;
  final String name;

  Organization({
    required this.id,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json["id"] as int? ?? 0,
    name: json["name"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
