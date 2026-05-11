import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';

class SharedPreferencesDataSource implements LocalStorageDataSource {
  static const String _highScoreKey = 'aura_glide_high_score';

  final SharedPreferences _prefs;

  SharedPreferencesDataSource(this._prefs);

  @override
  Future<int> getHighScore() async {
    return _prefs.getInt(_highScoreKey) ?? 0;
  }

  @override
  Future<void> saveHighScore(int score) async {
    await _prefs.setInt(_highScoreKey, score);
  }

  @override
  Future<void> clearHighScore() async {
    await _prefs.remove(_highScoreKey);
  }
}