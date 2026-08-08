class Weather {
  final double temperature;
  final String description;
  final String iconCode;
  final String cityName; // Thêm trường này

  Weather({
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.cityName,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // Xử lý temperature (đảm bảo nó là double, kể cả khi API trả về int)
    final tempValue = json['temperature'];
    double parsedTemp;

    if (tempValue is int) {
      parsedTemp = tempValue.toDouble();
    } else if (tempValue is double) {
      parsedTemp = tempValue;
    } else {
      // Trường hợp không phải int hoặc double
      throw const FormatException('Invalid data type for temperature.');
    }

    return Weather(
      temperature: parsedTemp,
      description: json['description'] as String,
      iconCode: json['iconCode'] as String,
      cityName: json['cityName'] as String, // Lấy tên thành phố từ API
    );
  }
}