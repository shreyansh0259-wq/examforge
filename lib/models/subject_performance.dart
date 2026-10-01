class SubjectPerformance {
  final String subject;

  int attempted = 0;
  int correct = 0;
  int incorrect = 0;

  SubjectPerformance({
    required this.subject,
  });

  double get accuracy {
    if (attempted == 0) return 0;
    return (correct / attempted) * 100;
  }
}
