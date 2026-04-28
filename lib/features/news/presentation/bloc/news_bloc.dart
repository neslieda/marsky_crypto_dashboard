import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();
  @override
  List<Object?> get props => const [];
}

class NewsLoadRequested extends NewsEvent {
  const NewsLoadRequested();
}

enum NewsStatus { initial, loading, success, failure }

class NewsState extends Equatable {
  final NewsStatus status;
  final List<NewsItem> items;
  final String? errorMessage;

  const NewsState({
    this.status = NewsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  NewsState copyWith({
    NewsStatus? status,
    List<NewsItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) =>
      NewsState(
        status: status ?? this.status,
        items: items ?? this.items,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, items, errorMessage];
}

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository repository;

  NewsBloc({required this.repository}) : super(const NewsState()) {
    on<NewsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
      NewsLoadRequested event, Emitter<NewsState> emit) async {
    emit(state.copyWith(status: NewsStatus.loading, clearError: true));
    final res = await repository.latest();
    res.fold(
      (f) => emit(state.copyWith(
          status: NewsStatus.failure, errorMessage: f.message)),
      (items) =>
          emit(state.copyWith(status: NewsStatus.success, items: items)),
    );
  }
}
