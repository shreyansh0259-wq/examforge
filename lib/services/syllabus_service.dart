import 'dart:convert';
import 'package:flutter/services.dart';

class SyllabusService {
  Future<List<Map<String, dynamic>>> getUnits(
    String exam,
    String subject,
  ) async {
    final path =
        'assets/data/syllabus/${exam.toLowerCase().replaceAll(' ', '_')}/${subject.toLowerCase()}.json';

    final jsonString = await rootBundle.loadString(path);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    return List<Map<String, dynamic>>.from(data['units'] ?? []);
  }
}
