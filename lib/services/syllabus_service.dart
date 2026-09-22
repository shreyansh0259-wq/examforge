import 'dart:convert';

import 'package:flutter/services.dart';

class SyllabusService {
  Future<List<Map<String, dynamic>>> getUnits(
    String exam,
    String subject,
  ) async {
    final normalizedExam =
        exam.toLowerCase().replaceAll(' ', '_');

    final normalizedSubject =
        subject.toLowerCase();

    if (normalizedExam == 'neet' &&
        normalizedSubject == 'biology') {
      final botanyUnits = await _loadUnits(
        'assets/data/syllabus/neet/botany.json',
      );

      final zoologyUnits = await _loadUnits(
        'assets/data/syllabus/neet/zoology.json',
      );

      return [
        ...botanyUnits,
        ...zoologyUnits,
      ];
    }

    final path =
        'assets/data/syllabus/$normalizedExam/$normalizedSubject.json';

    return _loadUnits(path);
  }

  Future<List<Map<String, dynamic>>> _loadUnits(
    String path,
  ) async {
    final jsonString = await rootBundle.loadString(path);

    final data =
        jsonDecode(jsonString) as Map<String, dynamic>;

    return List<Map<String, dynamic>>.from(
      data['units'] ?? [],
    );
  }
}
