import 'package:equatable/equatable.dart';

class NewsItem extends Equatable {
  final String id;
  final String title;
  final String url;
  final String? sourceName;
  final DateTime? publishedAt;
  final List<String> currencies;

  const NewsItem({
    required this.id,
    required this.title,
    required this.url,
    this.sourceName,
    this.publishedAt,
    this.currencies = const [],
  });

  @override
  List<Object?> get props => [id, title, url, publishedAt];
}
