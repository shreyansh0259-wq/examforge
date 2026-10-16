import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/mcc_allotment.dart';

class MccAllotmentImporter {
  Future<List<MccAllotment>> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw);

    if (data is! Map<String, dynamic> || data['records'] is! List) {
      throw const FormatException('Invalid MCC allotment JSON');
    }

    return (data['records'] as List)
        .whereType<Map<String, dynamic>>()
        .map(MccAllotment.fromJson)
        .toList();
  }
}
