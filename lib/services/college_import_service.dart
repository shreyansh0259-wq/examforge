import 'dart:convert';

import 'package:flutter/services.dart';

import 'college_database.dart';
import 'cutoff_data_validator.dart';

class CollegeImportService {
  Future<int> importJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw);

    if (json is! Map<String, dynamic>) {
      return 0;
    }

    final exam = json['exam'];
    final year = json['year'];
    final counselling = json['counselling'];
    final records = json['records'];

    if (exam is! String || exam.trim().isEmpty) {
      return 0;
    }

    if (year is! int || year < 2000) {
      return 0;
    }

    if (counselling is! String || counselling.trim().isEmpty) {
      return 0;
    }

    if (records is! List) {
      return 0;
    }

    var imported = 0;

    for (final item in records) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final normalized = {
        'exam': exam,
        'college': item['college'],
        'course': item['course'],
        'category': item['category'],
        'counselling': counselling,
        'quota': item['quota'],
        'state': item['state'],
        'institute_type': item['institute_type'],
        'year': year,
        'round': item['round'],
        'opening_rank': item['opening_rank'],
        'closing_rank': item['closing_rank'],
        'closing_score': item['closing_score'],
        'source': item['source'],
      };

      if (!CutoffDataValidator.isValid(normalized)) {
        continue;
      }

      await CollegeDatabase.instance.insertCutoff(normalized);

      imported++;
    }

    return imported;
  }
}
