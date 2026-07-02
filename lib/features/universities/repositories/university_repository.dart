import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/university.dart';

class UniversityRepository {
  UniversityRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<UniversityListResponse> fetchUniversities({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/universities').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': '$page',
        'page_size': '$pageSize',
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw UniversityApiException('Failed to load universities');
    }
    return UniversityListResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<University> fetchUniversity(int sourceId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/universities/$sourceId'),
    );
    if (response.statusCode == 404) {
      throw UniversityApiException('University not found');
    }
    if (response.statusCode != 200) {
      throw UniversityApiException('Failed to load university details');
    }
    return University.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }
}

class UniversityApiException implements Exception {
  final String message;

  const UniversityApiException(this.message);

  @override
  String toString() => message;
}
