class PublicHoliday {
  final DateTime date;
  final String localName;
  final String name;
  final String countryCode;
  final bool fixed;
  final bool global;
  final List<String> counties;
  final int? launchYear;
  final List<String> types;

  const PublicHoliday({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    this.fixed = false,
    this.global = false,
    this.counties = const [],
    this.launchYear,
    this.types = const [],
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    return PublicHoliday(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime(2000, 1, 1),
      localName: (json['localName'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      countryCode: (json['countryCode'] ?? '').toString(),
      fixed: json['fixed'] == true,
      global: json['global'] == true,
      counties: _parseStringList(json['counties']),
      launchYear: _parseInt(json['launchYear']),
      types: _parseStringList(json['types']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T').first,
      'localName': localName,
      'name': name,
      'countryCode': countryCode,
      'fixed': fixed,
      'global': global,
      'counties': counties.isEmpty ? null : counties,
      'launchYear': launchYear,
      'types': types,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];

    return value.map((item) => item.toString()).toList();
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
