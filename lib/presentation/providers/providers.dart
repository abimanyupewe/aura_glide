import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/swap_blocks.dart';
import '../../domain/usecases/detect_matches.dart';
import '../../domain/usecases/apply_gravity.dart';
import '../../domain/usecases/calculate_score.dart';
import '../../domain/usecases/refill_grid.dart';
import '../../domain/repositories/score_repository.dart';
import '../../data/repositories/score_repository_impl.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/shared_preferences_datasource.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final localStorageProvider = Provider<LocalStorageDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesDataSource(prefs);
});

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  final dataSource = ref.watch(localStorageProvider);
  return ScoreRepositoryImpl(dataSource);
});

final swapBlocksProvider = Provider<SwapBlocks>((ref) => SwapBlocks());
final detectMatchesProvider = Provider<DetectMatches>((ref) => DetectMatches());
final applyGravityProvider = Provider<ApplyGravity>((ref) => ApplyGravity());
final calculateScoreProvider = Provider<CalculateScore>((ref) => CalculateScore());
final refillGridProvider = Provider<RefillGrid>((ref) => RefillGrid());