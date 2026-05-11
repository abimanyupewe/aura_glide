class CalculateScore {
  static const int basePointsPerBlock = 10;
  static const int additionalPointsPerBlock = 5;

  int execute(int matchLength, int cascadeMultiplier) {
    final basePoints = basePointsPerBlock +
        ((matchLength - 3) * additionalPointsPerBlock);

    return basePoints * cascadeMultiplier;
  }

  ScoreBreakdown calculateBreakdown(int matchLength, int cascadeMultiplier) {
    final basePoints = basePointsPerBlock +
        ((matchLength - 3) * additionalPointsPerBlock);
    final totalPoints = basePoints * cascadeMultiplier;

    return ScoreBreakdown(
      basePoints: basePoints,
      multiplier: cascadeMultiplier,
      totalPoints: totalPoints,
      blockCount: matchLength,
    );
  }
}

class ScoreBreakdown {
  final int basePoints;
  final int multiplier;
  final int totalPoints;
  final int blockCount;

  const ScoreBreakdown({
    required this.basePoints,
    required this.multiplier,
    required this.totalPoints,
    required this.blockCount,
  });
}