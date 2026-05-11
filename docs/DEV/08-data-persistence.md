# Data Persistence - AuraGlide

Dokumen ini menjelaskan implementasi persistensi data untuk menyimpan high score menggunakan local storage.

## 1. Pilihan Teknologi

Berdasarkan PRD Section 5:
- **shared_preferences** atau **Hive** untuk local storage
- Hanya menyimpan angka High Score

Perbandingan:
| Fitur | SharedPreferences | Hive |
|-------|-------------------|------|
| Kompleksitas | Simple | Medium |
| Performance | Good | Excellent |
| Type Safety | No | Yes (with generator) |
| Bundle Size | Small | Medium |

**Rekomendasi:** SharedPreferences untuk simplicity, atau Hive jika ingin extensibility.

## 2. SharedPreferences Implementation

### Data Source Interface

```dart
// domain/repositories/score_repository.dart
abstract class ScoreRepository {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<void> clearHighScore();
}
```

### Local Storage Data Source

```dart
// data/datasources/local_storage.dart
abstract class LocalStorageDataSource {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<void> clearHighScore();
}
```

### SharedPreferences Implementation

```dart
// data/datasources/shared_preferences_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';

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
```

### Repository Implementation

```dart
// data/repositories/score_repository_impl.dart
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
```

## 3. Hive Implementation (Alternative)

### Setup Hive

```dart
// main.dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open boxes
  await Hive.openBox<int>('scores');

  runApp(
    const ProviderScope(
      child: AuraGlideApp(),
    ),
  );
}
```

### Hive Data Source

```dart
// data/datasources/hive_datasource.dart
import 'package:hive/hive.dart';

class HiveDataSource implements LocalStorageDataSource {
  static const String _boxName = 'scores';
  static const String _highScoreKey = 'high_score';

  Box<int> get _box => Hive.box<int>(_boxName);

  @override
  Future<int> getHighScore() async {
    return _box.get(_highScoreKey, defaultValue: 0) ?? 0;
  }

  @override
  Future<void> saveHighScore(int score) async {
    await _box.put(_highScoreKey, score);
  }

  @override
  Future<void> clearHighScore() async {
    await _box.delete(_highScoreKey);
  }
}
```

## 4. Provider Setup

```dart
// presentation/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/score_repository.dart';
import '../../data/repositories/score_repository_impl.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/shared_preferences_datasource.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// Data source provider
final localStorageProvider = Provider<LocalStorageDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesDataSource(prefs);
});

// Repository provider
final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  final dataSource = ref.watch(localStorageProvider);
  return ScoreRepositoryImpl(dataSource);
});
```

## 5. Inisialisasi di main.dart

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AuraGlideApp(),
    ),
  );
}
```

## 6. Penggunaan di Game Provider

```dart
// presentation/providers/game_provider.dart
class GameNotifier extends StateNotifier<GameState> {
  final ScoreRepository _scoreRepository;

  // ... constructor dan lain lain

  Future<void> _initializeGame() async {
    // Load high score dari storage
    final highScore = await _scoreRepository.getHighScore();

    state = state.copyWith(
      grid: _generateInitialGrid(),
      highScore: highScore,
      status: GameStatus.playing,
    );
  }

  Future<void> _updateScore(int score) async {
    final newHighScore = score > state.highScore ? score : state.highScore;

    if (newHighScore > state.highScore) {
      await _scoreRepository.saveHighScore(newHighScore);
    }

    state = state.copyWith(
      score: score,
      highScore: newHighScore,
    );
  }
}
```

## 7. State Management untuk High Score

```dart
// presentation/providers/score_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// High score stream provider
final highScoreProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(scoreRepositoryProvider);
  return await repository.getHighScore();
});

// Score manager untuk update
final scoreManagerProvider = Provider<ScoreManager>((ref) {
  return ScoreManager(ref);
});

class ScoreManager {
  final Ref _ref;

  ScoreManager(this._ref);

  Future<void> updateIfHigher(int score) async {
    final repository = _ref.read(scoreRepositoryProvider);
    final currentHigh = await repository.getHighScore();

    if (score > currentHigh) {
      await repository.saveHighScore(score);
      _ref.invalidate(highScoreProvider);
    }
  }

  Future<void> resetHighScore() async {
    final repository = _ref.read(scoreRepositoryProvider);
    await repository.clearHighScore();
    _ref.invalidate(highScoreProvider);
  }
}
```

## 8. Testing

```dart
// test/data/datasources/shared_preferences_datasource_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura_glide/data/datasources/shared_preferences_datasource.dart';

void main() {
  late SharedPreferencesDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(prefs);
  });

  test('should return 0 when no high score saved', () async {
    final result = await dataSource.getHighScore();
    expect(result, 0);
  });

  test('should save and retrieve high score', () async {
    await dataSource.saveHighScore(100);
    final result = await dataSource.getHighScore();
    expect(result, 100);
  });

  test('should overwrite existing high score', () async {
    await dataSource.saveHighScore(100);
    await dataSource.saveHighScore(200);
    final result = await dataSource.getHighScore();
    expect(result, 200);
  });

  test('should clear high score', () async {
    await dataSource.saveHighScore(100);
    await dataSource.clearHighScore();
    final result = await dataSource.getHighScore();
    expect(result, 0);
  });
}
```

## 9. Error Handling

```dart
// data/datasources/local_storage.dart
abstract class LocalStorageDataSource {
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  Future<void> clearHighScore();
}

class LocalStorageException implements Exception {
  final String message;
  LocalStorageException(this.message);

  @override
  String toString() => 'LocalStorageException: $message';
}

// With error handling
class SafeLocalStorageDataSource implements LocalStorageDataSource {
  final LocalStorageDataSource _delegate;

  SafeLocalStorageDataSource(this._delegate);

  @override
  Future<int> getHighScore() async {
    try {
      return await _delegate.getHighScore();
    } catch (e) {
      // Fallback to 0 on error
      return 0;
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      await _delegate.saveHighScore(score);
    } catch (e) {
      // Log error but don't crash
      debugPrint('Failed to save high score: $e');
    }
  }

  @override
  Future<void> clearHighScore() async {
    try {
      await _delegate.clearHighScore();
    } catch (e) {
      debugPrint('Failed to clear high score: $e');
    }
  }
}
```

## 10. Keamanan Catatan

- SharedPreferences tidak terenkripsi - cocok untuk high score karena bukan data sensitif
- Jangan pernah menyimpan credentials/password di SharedPreferences
- Untuk extensibility masa depan, bisa upgrade ke Hive dengan encryption

---

**Referensi:**
- PRD Section 5: "Local DB: shared_preferences atau hive"
- Flutter SharedPreferences Documentation