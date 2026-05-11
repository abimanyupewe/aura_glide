import '../../domain/repositories/score_repository.dart';
import '../datasources/local_storage.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final LocalStorageDataSource _dataSource;

  ScoreRepositoryImpl(this._dataSource);

  @override
  Future<int> getHighScore() async {
    return await _dataSource.getHighScore();
  }

  @override
  Future<void> saveHighScore(int score) async {
    final currentHighScore = await getHighScore();
    if (score > currentHighScore) {
      await _dataSource.saveHighScore(score);
    }
  }

  @override
  Future<void> clearHighScore() async {
    await _dataSource.clearHighScore();
  }
}