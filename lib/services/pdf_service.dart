import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/question.dart';

class PdfService {
  Future<File> generateQuestionPaper({
    required List<Question> questions,
    required String exam,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'ExamForge - $exam',
            style: pw.TextStyle(fontSize: 22),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total Questions: ${questions.length}'),
          pw.SizedBox(height: 20),
          ...questions.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final q = entry.value;

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('$index. ${q.question}'),
                  pw.SizedBox(height: 6),
                  ...q.options.asMap().entries.map(
                    (option) => pw.Text(
                      '${String.fromCharCode(65 + option.key)}. ${option.value}',
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/ExamForge_Test.pdf',
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> generateOmrSheet({
    required int questionCount,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'ExamForge OMR Answer Sheet',
              style: pw.TextStyle(fontSize: 20),
            ),
          ),
          pw.SizedBox(height: 20),
          ...List.generate(questionCount, (index) {
            final number = index + 1;

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                '$number.    ○ A     ○ B     ○ C     ○ D',
              ),
            );
          }),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/ExamForge_OMR.pdf',
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
