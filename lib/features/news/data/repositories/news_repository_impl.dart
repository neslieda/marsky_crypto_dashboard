import 'package:dartz/dartz.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _ds;
  NewsRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<NewsItem>>> latest() async {
    try {
      final items = await _ds.latest();
      return Right(items);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
