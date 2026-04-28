import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/config/app_env.dart';
import '../../../../core/error/exceptions.dart';

/// Thin client over OpenAI Chat Completions API.
abstract class OpenAiDataSource {
  /// Returns the assistant message content for a single-turn chat completion.
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    double temperature,
    int maxTokens,
  });
}

class OpenAiDataSourceImpl implements OpenAiDataSource {
  OpenAiDataSourceImpl({Dio? dio, String? model})
      : _model = model ?? 'gpt-4o',
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.openai.com/v1',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppEnv.openAiApiKey}',
              },
            ));

  final Dio _dio;
  final String _model;

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.4,
    int maxTokens = 600,
  }) async {
    if (AppEnv.openAiApiKey.isEmpty) {
      throw const ServerException('OpenAI API key is not configured.');
    }
    try {
      final res = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': _model,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
        }),
      );
      final body = res.data as Map<String, dynamic>;
      final choices = (body['choices'] as List?) ?? const [];
      if (choices.isEmpty) {
        throw const ServerException('OpenAI returned no choices.');
      }
      final msg = (choices.first as Map<String, dynamic>)['message']
          as Map<String, dynamic>;
      final content = (msg['content'] as String?)?.trim();
      if (content == null || content.isEmpty) {
        throw const ServerException('OpenAI returned an empty response.');
      }
      return content;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      throw ServerException('OpenAI request failed ($status): $data');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
