class CollegeAnalysis {
  final String exam;
  final int year;
  final String category;
  final String counselling;
  final int score;
  final int? estimatedRank;
  final List<String> possibleColleges;
  final List<String> nextBetterColleges;

  const CollegeAnalysis({
    required this.exam,
    required this.year,
    required this.category,
    required this.counselling,
    required this.score,
    required this.estimatedRank,
    required this.possibleColleges,
    required this.nextBetterColleges,
  });

  const CollegeAnalysis.empty({
    required this.exam,
    required this.year,
    required this.category,
    required this.counselling,
    required this.score,
  })  : estimatedRank = null,
        possibleColleges = const [],
        nextBetterColleges = const [];
}
