class TopicPerformance {
  final String subject;
  final String chapter;
  final String topic;

  int attempted = 0;
  int correct = 0;
  int incorrect = 0;

  TopicPerformance({
    required this.subject,
    required this.chapter,
    required this.topic,
  });

  double get accuracy {
    if (attempted == 0) return 0;
    return (correct / attempted) * 100;
  }

  bool get isWeak => attempted > 0 && accuracy < 60;
}
