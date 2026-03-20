class AppConfig {
  final bool fullScreenMode;

  AppConfig({required this.fullScreenMode});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      fullScreenMode: json['fullScreenMode'] ?? false,
    );
  }
}
