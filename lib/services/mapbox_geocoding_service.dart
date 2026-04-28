import 'dart:convert';

import 'package:http/http.dart' as http;

/// Forward geocoding suggestions (Mapbox Geocoding API). Does not log tokens.
class MapboxGeocodingService {
  MapboxGeocodingService({required this.accessToken, http.Client? client})
      : _client = client ?? http.Client();

  final String accessToken;
  final http.Client _client;

  static const _host = 'api.mapbox.com';

  Future<List<MapboxPlaceSuggestion>> forwardAutocomplete({
    required String query,
    String country = 'us',
  }) async {
    final q = query.trim();
    if (q.isEmpty || accessToken.isEmpty) return [];

    final encoded = Uri.encodeComponent(q);
    final uri = Uri(
      scheme: 'https',
      host: _host,
      path: '/geocoding/v5/mapbox.places/$encoded.json',
      queryParameters: <String, String>{
        'access_token': accessToken,
        'autocomplete': 'true',
        'country': country,
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return [];
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? const [];
    return features
        .map((e) => MapboxPlaceSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}

class MapboxPlaceSuggestion {
  MapboxPlaceSuggestion({required this.id, required this.placeName});

  final String id;
  final String placeName;

  factory MapboxPlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final placeName = json['place_name'] as String? ?? '';
    return MapboxPlaceSuggestion(id: id, placeName: placeName);
  }
}
