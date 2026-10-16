import '../importer/mcc_allotment_importer.dart';
import '../models/mcc_allotment.dart';

class MccAllotmentService {
  MccAllotmentService({MccAllotmentImporter? importer})
      : _importer = importer ?? MccAllotmentImporter();

  final MccAllotmentImporter _importer;
  List<MccAllotment>? _cachedRecords;

  Future<List<MccAllotment>> loadRound1_2025() async {
    if (_cachedRecords != null) return _cachedRecords!;

    _cachedRecords = await _importer.loadFromAsset(
      'assets/data/college_cutoffs/neet/2025/mcc_round1_2025.json',
    );

    return _cachedRecords!;
  }

  Future<List<MccAllotment>> search({
    num? rank,
    String? course,
    String? quota,
    String? college,
  }) async {
    final records = await loadRound1_2025();

    return records.where((record) {
      if (rank != null && record.rank != rank) return false;
      if (course != null &&
          record.course.toLowerCase() != course.toLowerCase()) {
        return false;
      }
      if (quota != null &&
          (record.quota ?? '').toLowerCase() != quota.toLowerCase()) {
        return false;
      }
      if (college != null &&
          !record.collegeRaw.toLowerCase().contains(college.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }
}
