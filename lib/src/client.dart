import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

/// Client for the unfurlr API.
///
/// Keys: on Flutter Web pass a publishable `pk_...` key (origin-locked, own small quota).
/// Never ship the secret `mk_...` key in an app. On Android/iOS/desktop (no `Origin` header),
/// call your own backend proxy via [baseUrl] instead. Server-side Dart may use the secret key.
class UnfurlrClient {
  final String baseUrl;
  final String? apiKey;
  /// Free tier sleeps when idle and can take ~60 s to wake.
  final Duration timeout;
  final http.Client _http;
  final bool _ownsClient;

  UnfurlrClient({
    this.apiKey,
    String baseUrl = 'https://unfurlr.onrender.com',
    this.timeout = const Duration(seconds: 60),
    http.Client? httpClient,
  })  : baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _http = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (apiKey != null) 'X-API-Key': apiKey!,
      };

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? q]) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: q);
    final r = await _http.get(uri, headers: _headers).timeout(timeout);
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      body = null;
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      String? code;
      var msg = r.reasonPhrase ?? 'HTTP ${r.statusCode}';
      if (body is Map) {
        final e = body['error'] ?? body['detail'];
        if (e is Map) {
          code = e['code']?.toString();
          msg = e['message']?.toString() ?? msg;
        } else if (e != null) {
          msg = e.toString();
        }
      }
      throw UnfurlrException(r.statusCode, msg, code: code);
    }
    if (body is! Map) throw UnfurlrException(r.statusCode, 'Invalid JSON response');
    return Map<String, dynamic>.from(body);
  }

  /// Fetch preview metadata for [url]. [fresh] skips the cache.
  Future<UnfurlrMetadata> metadata(String url, {bool fresh = false}) async =>
      UnfurlrMetadata.fromJson(await _get('/v1/metadata', {'url': url, if (fresh) 'fresh': 'true'}));

  /// Current usage for this key.
  Future<UnfurlrUsage> usage() async => UnfurlrUsage.fromJson(await _get('/v1/usage'));

  void close() {
    if (_ownsClient) _http.close();
  }
}
