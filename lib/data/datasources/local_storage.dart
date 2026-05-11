abstract class LocalStorageDataSource {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<void> clearHighScore();
}