class CollegeCutoff {
  final String exam;
  final String college;
  final String course;
  final String category;
  final String counselling;
  final String? quota;
  final String? state;
  final String? instituteType;
  final int year;
  final int round;
  final int? openingRank;
  final int? closingRank;
  final int? closingScore;
  final String source;

  String get recordKey {
    return [
      exam,
      year,
      counselling,
      round,
      college,
      course,
      category,
      quota ?? '',
      state ?? '',
    ].join('|').toLowerCase();
  }

  const CollegeCutoff({
    required this.exam,
    required this.college,
    required this.course,
    required this.category,
    required this.counselling,
    this.quota,
    this.state,
    this.instituteType,
    required this.year,
    required this.round,
    required this.openingRank,
    required this.closingRank,
    required this.closingScore,
    required this.source,
  });
}
