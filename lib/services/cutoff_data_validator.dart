class CutoffDataValidator {
  static bool isValid(Map<String, dynamic> record) {
    return record['exam'] != null &&
        record['college'] != null &&
        record['course'] != null &&
        record['category'] != null &&
        record['year'] != null &&
        record['round'] != null &&
        record['source'] != null;
  }
}
