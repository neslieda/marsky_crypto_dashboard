import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsky_crypto_dashboard/core/error/failures.dart';
import 'package:marsky_crypto_dashboard/features/coins/domain/entities/coin.dart';
import 'package:marsky_crypto_dashboard/features/coins/domain/entities/coin_sort.dart';
import 'package:marsky_crypto_dashboard/features/coins/domain/usecases/get_coins_paginated.dart';
import 'package:marsky_crypto_dashboard/features/coins/presentation/bloc/coins_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCoinsPaginated extends Mock implements GetCoinsPaginated {}

Coin _coin(String id) => Coin(uuid: id, name: 'Coin $id', symbol: id);

CoinsPage _page(List<Coin> coins, {required int total, required int offset}) =>
    CoinsPage(coins: coins, total: total, offset: offset, limit: 25);

void main() {
  late _MockGetCoinsPaginated useCase;

  setUpAll(() {
    registerFallbackValue(CoinSortBy.marketCap);
    registerFallbackValue(CoinSortDirection.desc);
  });

  setUp(() {
    useCase = _MockGetCoinsPaginated();
  });

  CoinsListBloc build() => CoinsListBloc(getCoinsPaginated: useCase);

  test('initial state is initial with default sort', () {
    final state = build().state;
    expect(state.status, CoinsListStatus.initial);
    expect(state.coins, isEmpty);
    expect(state.sortBy, CoinSortBy.marketCap);
    expect(state.direction, CoinSortDirection.desc);
  });

  group('CoinsListLoadRequested', () {
    blocTest<CoinsListBloc, CoinsListState>(
      'emits loading then success with coins',
      setUp: () {
        when(() => useCase(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              orderBy: any(named: 'orderBy'),
              direction: any(named: 'direction'),
            )).thenAnswer(
          (_) async => Right(
            _page([_coin('a'), _coin('b')], total: 2, offset: 0),
          ),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const CoinsListLoadRequested()),
      expect: () => [
        isA<CoinsListState>().having(
          (s) => s.status,
          'status',
          CoinsListStatus.loading,
        ),
        isA<CoinsListState>()
            .having((s) => s.status, 'status', CoinsListStatus.success)
            .having((s) => s.coins.length, 'coins.length', 2)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<CoinsListBloc, CoinsListState>(
      'emits failure with error message',
      setUp: () {
        when(() => useCase(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              orderBy: any(named: 'orderBy'),
              direction: any(named: 'direction'),
            )).thenAnswer(
          (_) async => const Left(NetworkFailure('no net')),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const CoinsListLoadRequested()),
      expect: () => [
        isA<CoinsListState>()
            .having((s) => s.status, 'status', CoinsListStatus.loading),
        isA<CoinsListState>()
            .having((s) => s.status, 'status', CoinsListStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'no net'),
      ],
    );
  });

  group('CoinsListLoadMoreRequested', () {
    blocTest<CoinsListBloc, CoinsListState>(
      'appends new coins on success',
      setUp: () {
        when(() => useCase(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              orderBy: any(named: 'orderBy'),
              direction: any(named: 'direction'),
            )).thenAnswer(
          (_) async => Right(_page([_coin('c')], total: 3, offset: 2)),
        );
      },
      build: build,
      seed: () => CoinsListState(
        status: CoinsListStatus.success,
        coins: [_coin('a'), _coin('b')],
        hasMore: true,
        total: 3,
      ),
      act: (bloc) => bloc.add(const CoinsListLoadMoreRequested()),
      expect: () => [
        isA<CoinsListState>()
            .having((s) => s.status, 'status', CoinsListStatus.loadingMore),
        isA<CoinsListState>()
            .having((s) => s.status, 'status', CoinsListStatus.success)
            .having((s) => s.coins.length, 'coins.length', 3)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<CoinsListBloc, CoinsListState>(
      'does nothing when hasMore is false',
      build: build,
      seed: () => const CoinsListState(
        status: CoinsListStatus.success,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const CoinsListLoadMoreRequested()),
      expect: () => const <CoinsListState>[],
      verify: (_) => verifyNever(() => useCase(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
            orderBy: any(named: 'orderBy'),
            direction: any(named: 'direction'),
          )),
    );

    blocTest<CoinsListBloc, CoinsListState>(
      'does nothing when already loading more',
      build: build,
      seed: () => const CoinsListState(
        status: CoinsListStatus.loadingMore,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const CoinsListLoadMoreRequested()),
      expect: () => const <CoinsListState>[],
    );
  });

  group('CoinsListSortChanged', () {
    blocTest<CoinsListBloc, CoinsListState>(
      'resets coins, updates sort, and reloads',
      setUp: () {
        when(() => useCase(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              orderBy: any(named: 'orderBy'),
              direction: any(named: 'direction'),
            )).thenAnswer(
          (_) async => Right(_page([_coin('x')], total: 1, offset: 0)),
        );
      },
      build: build,
      seed: () => CoinsListState(
        status: CoinsListStatus.success,
        coins: [_coin('a')],
        sortBy: CoinSortBy.marketCap,
      ),
      act: (bloc) => bloc.add(const CoinsListSortChanged(
        sortBy: CoinSortBy.price,
        direction: CoinSortDirection.asc,
      )),
      verify: (bloc) {
        expect(bloc.state.sortBy, CoinSortBy.price);
        expect(bloc.state.direction, CoinSortDirection.asc);
        verify(() => useCase(
              limit: any(named: 'limit'),
              offset: 0,
              orderBy: CoinSortBy.price,
              direction: CoinSortDirection.asc,
            )).called(1);
      },
    );
  });
}
