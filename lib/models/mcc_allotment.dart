class MccAllotment {
  final int serial;
  final num rank;
  final int page;
  final String course;
  final List<String> categoryFields;
  final String? quota;
  final String collegeRaw;
  final String? raw;

  const MccAllotment({
    required this.serial,
    required this.rank,
    required this.page,
    required this.course,
    required this.categoryFields,
    required this.quota,
    required this.collegeRaw,
    this.raw,
  });

  factory MccAllotment.fromJson(Map<String, dynamic> json) {
    return MccAllotment(
      serial: json['serial'] as int,
      rank: json['rank'] as num,
      page: json['page'] as int,
      course: json['course'] as String,
      categoryFields:
          List<String>.from(json['category_fields'] as List),
      quota: json['quota'] as String?,
      collegeRaw: json['college_raw'] as String,
      raw: json['raw'] as String?,
    );
  }
}
