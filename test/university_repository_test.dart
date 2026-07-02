import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nqaae_app/features/universities/repositories/university_repository.dart';

void main() {
  test('fetchUniversities sends search and paging query parameters', () async {
    Uri? requestedUri;
    final repository = UniversityRepository(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '{"items":[],"page":3,"page_size":12,"total":0,"pages":0}',
          200,
        );
      }),
    );

    await repository.fetchUniversities(
      search: 'samarqand',
      page: 3,
      pageSize: 12,
    );

    expect(requestedUri?.path, '/api/universities');
    expect(requestedUri?.queryParameters['search'], 'samarqand');
    expect(requestedUri?.queryParameters['page'], '3');
    expect(requestedUri?.queryParameters['page_size'], '12');
  });
}
