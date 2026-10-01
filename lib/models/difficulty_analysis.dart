class DifficultyAnalysis {
  final String difficulty;
  final double multiplier;

  const DifficultyAnalysis({
    required this.difficulty,
    required this.multiplier,
  });

  double getEquivalentScore(int rawScore) {
    return rawScore * multiplier;
  }

  static DifficultyAnalysis fromDifficulty(String? difficulty) {
    switch (difficulty) {
      case 'Very Easy':
        return const DifficultyAnalysis(
          difficulty: 'Very Easy',
          multiplier: 0.90,
        );

      case 'Easy':
        return const DifficultyAnalysis(
          difficulty: 'Easy',
          multiplier: 0.95,
        );

      case 'Easy-Moderate':
        return const DifficultyAnalysis(
          difficulty: 'Easy-Moderate',
          multiplier: 0.98,
        );

      case 'Moderate':
        return const DifficultyAnalysis(
          difficulty: 'Moderate',
          multiplier: 1.00,
        );

      case 'Moderate+':
        return const DifficultyAnalysis(
          difficulty: 'Moderate+',
          multiplier: 1.03,
        );

      case 'Hard':
        return const DifficultyAnalysis(
          difficulty: 'Hard',
          multiplier: 1.07,
        );

      case 'Very Hard':
        return const DifficultyAnalysis(
          difficulty: 'Very Hard',
          multiplier: 1.12,
        );

      case 'Advanced':
        return const DifficultyAnalysis(
          difficulty: 'Advanced',
          multiplier: 1.17,
        );

      case 'Expert':
        return const DifficultyAnalysis(
          difficulty: 'Expert',
          multiplier: 1.22,
        );

      case 'Extreme Challenge':
        return const DifficultyAnalysis(
          difficulty: 'Extreme Challenge',
          multiplier: 1.27,
        );

      default:
        return const DifficultyAnalysis(
          difficulty: 'Mixed',
          multiplier: 1.00,
        );
    }
  }
}
