import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsky_crypto_dashboard/core/error/failures.dart';
import 'package:marsky_crypto_dashboard/features/favorites/domain/entities/favorite_coin.dart';
import 'package:marsky_crypto_dashboard/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:marsky_crypto_dashboard/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:marsky_crypto_dashboard/features/favorites/domain/usecases/watch_favorites.dart';
import 'package:marsky_crypto_dashboard/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements FavoritesRepository {}

class _MockWatch extends Mock implements WatchFavorites {}

class _MockToggle extends Mock implements ToggleFavorite {}

FavoriteCoin _fav(String id) => FavoriteCoin(
      uuid: id,
      name: 'Coin $id',
      symbol: id,
      addedAt: DateTime.utc(2024, 1, 1),
    );

void main() {
  late _MockRepo repo;
  late _MockWatch watch;
  late _MockToggle toggle;

  setUpAll(() {
    registerFallbackValue(_fav('fallback'));
  });

  setUp(() {
    repo = _MockRepo();
    watch = _MockWatch();
    toggle = _MockToggle();
    when(() => repo.close()).thenAnswer((_) async => const Right(null));
  });

  FavoritesBloc build() => FavoritesBloc(
        repository: repo,
        watchFavorites: watch,
        toggleFavorite: toggle,
      );

  test('initial state is initial empty', () {
    final state = build().state;
    expect(state.status, FavoritesStatus.initial);
    expect(state.favorites, isEmpty);
  });

  group('FavoritesUserChanged', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'emits loading then success when stream emits favorites',
      setUp: () {
        when(() => repo.open(any())).thenAnswer((_) async => const Right(null));
        when(() => watch()).thenAnswer((_) => Stream.value([_fav('a')]));
      },
      build: build,
      act: (bloc) => bloc.add(const FavoritesUserChanged('user-1')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.status, 'status', FavoritesStatus.loading),
        isA<FavoritesState>()
            .having((s) => s.status, 'status', FavoritesStatus.success)
            .having((s) => s.favorites.length, 'favorites.length', 1),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'emits failure when repository.open fails',
      setUp: () {
        when(() => repo.open(any()))
            .thenAnswer((_) async => const Left(CacheFailure('disk full')));
      },
      build: build,
      act: (bloc) => bloc.add(const FavoritesUserChanged('user-1')),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.status, 'status', FavoritesStatus.loading),
        isA<FavoritesState>()
            .having((s) => s.status, 'status', FavoritesStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'disk full'),
      ],
    );
  });

  group('FavoritesUserCleared', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'resets state and closes repository',
      build: build,
      seed: () => FavoritesState(
        status: FavoritesStatus.success,
        favorites: [_fav('a')],
      ),
      act: (bloc) => bloc.add(const FavoritesUserCleared()),
      expect: () => [const FavoritesState()],
      verify: (_) => verify(() => repo.close()).called(greaterThanOrEqualTo(1)),
    );
  });

  group('FavoritesToggled', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'sets errorMessage on failure',
      setUp: () => when(() => toggle(any())).thenAnswer(
        (_) async => const Left(CacheFailure('write fail')),
      ),
      build: build,
      act: (bloc) => bloc.add(FavoritesToggled(_fav('a'))),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.errorMessage, 'errorMessage', 'write fail'),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'no state change on success',
      setUp: () =>
          when(() => toggle(any())).thenAnswer((_) async => const Right(true)),
      build: build,
      act: (bloc) => bloc.add(FavoritesToggled(_fav('a'))),
      expect: () => const <FavoritesState>[],
    );
  });

  group('isFavorite helper', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'returns true when uuid is in favorites stream',
      setUp: () {
        when(() => repo.open(any())).thenAnswer((_) async => const Right(null));
        when(() => watch())
            .thenAnswer((_) => Stream.value([_fav('a'), _fav('b')]));
      },
      build: build,
      act: (bloc) => bloc.add(const FavoritesUserChanged('user-1')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.isFavorite('a'), isTrue);
        expect(bloc.isFavorite('z'), isFalse);
      },
    );
  });
}
