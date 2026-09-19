import 'dart:convert';

import 'package:flutter/services.dart';

import '../database/question_database.dart';
import '../models/question.dart';

class QuestionImporter {
  final QuestionDatabase _database = QuestionDatabase.instance;

  Future<int> importFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final data = jsonDecode(jsonString);

    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid questions JSON format');
    }

    final questions = data['questions'];

    if (questions is! List) {
      throw const FormatException('Questions list not found');
    }

    int imported = 0;

    for (final item in questions) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final question = Question.fromJson(item);
      final result = await _database.insertQuestion(question.toMap());

      if (result != 0) {
        imported++;
      }
    }

    return imported;
  }
}
