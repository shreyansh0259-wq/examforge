import 'dart:convert';

import 'package:flutter/services.dart';

import 'college_database.dart';

class CollegeImportService {
  Future<int> importJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final records = json['records'] as List<dynamic>? ?? [];

    var imported = 0;

    for (final item in records) {
      final record = item as Map<String, dynamic>;

      await CollegeDatabase.instance.insertCutoff({
        'exam': json['exam'],
        'college': record['college'],
        'course': record['course'],
        'category': record['category'],
        'counselling': json['counselling'],
        'year': json['year'],
        'round': record['round'],
        'opening_rank': record['opening_rank'],
        'closing_rank': record['closing_rank'],
        'closing_score': record['closing_score'],
        'source': record['source'],
      });

      imported++;
    }

    return imported;
  }
}
