import '../models/college_cutoff.dart';

class CollegeCutoffService {
  final List<CollegeCutoff> _cutoffs = [];

  void addCutoff(CollegeCutoff cutoff) {
    _cutoffs.add(cutoff);
  }

  List<CollegeCutoff> find({
    required String exam,
    required int year,
    String? category,
    String? counselling,
    String? course,
  }) {
    return _cutoffs.where((cutoff) {
      if (cutoff.exam.toLowerCase() != exam.toLowerCase()) {
        return false;
      }

      if (cutoff.year != year) {
        return false;
      }

      if (category != null &&
          cutoff.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }

      if (counselling != null &&
          cutoff.counselling.toLowerCase() != counselling.toLowerCase()) {
        return false;
      }

      if (course != null &&
          cutoff.course.toLowerCase() != course.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  List<CollegeCutoff> findByRank({
    required String exam,
    required int year,
    required int rank,
    String? category,
    String? counselling,
    String? course,
  }) {
    return find(
      exam: exam,
      year: year,
      category: category,
      counselling: counselling,
      course: course,
    ).where((cutoff) {
      if (cutoff.closingRank == null) {
        return false;
      }

      return rank <= cutoff.closingRank!;
    }).toList();
  }
}
