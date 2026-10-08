class CutoffDataValidator {
  static bool isValid(Map<String, dynamic> record) {
    final exam = record['exam'];
    final college = record['college'];
    final course = record['course'];
    final category = record['category'];
    final year = record['year'];
    final round = record['round'];
    final source = record['source'];

    if (exam is! String || exam.trim().isEmpty) return false;
    if (college is! String || college.trim().isEmpty) return false;
    if (course is! String || course.trim().isEmpty) return false;
    if (category is! String || category.trim().isEmpty) return false;
    if (year is! int || year < 2000) return false;
    if (round is! int || round < 1) return false;
    if (source is! String || source.trim().isEmpty) return false;

    final openingRank = record['opening_rank'];
    final closingRank = record['closing_rank'];
    final closingScore = record['closing_score'];

    if (openingRank != null && openingRank is! int) return false;
    if (closingRank != null && closingRank is! int) return false;
    if (closingScore != null && closingScore is! int) return false;

    if (openingRank != null && openingRank < 1) return false;
    if (closingRank != null && closingRank < 1) return false;
    if (closingScore != null && closingScore < 0) return false;

    if (openingRank != null &&
        closingRank != null &&
        openingRank > closingRank) {
      return false;
    }

    if (closingRank == null && closingScore == null) {
      return false;
    }

    return true;
  }
}
