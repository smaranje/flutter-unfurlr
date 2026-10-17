// Live check of publishable (pk_) key behaviour; skipped unless UNFURLR_PUBLISHABLE_KEY is set.
// Runs against https://unfurlr.onrender.com unless UNFURLR_BASE_URL is set.
// UNFURLR_TEST_ORIGIN must be on the key's allowlist (default http://localhost:3000).
// The Origin header is added here only to simulate what a browser (Flutter Web) sends automatically.
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:unfurlr/unfurlr.dart';

class _WithOrigin extends http.BaseClient {
  final String origin;
  final http.Client _inner = http.Client();
  _WithOrigin(this.origin);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Origin'] = origin;
    return _inner.send(request);
  }
}

void main() {
  final base = Platform.environment['UNFURLR_BASE_URL'] ?? 'https://unfurlr.onrender.com';
  final pk = Platform.environment['UNFURLR_PUBLISHABLE_KEY'];
  final origin = Platform.environment['UNFURLR_TEST_ORIGIN'] ?? 'http://localhost:3000';
  final skip = pk == null ? 'set UNFURLR_PUBLISHABLE_KEY (and UNFURLR_TEST_ORIGIN)' : null;

  test('pk_ works from an allowed origin (Flutter Web)', () async {
    final c = UnfurlrClient(baseUrl: base, apiKey: pk, httpClient: _WithOrigin(origin));
    final m = await c.metadata('https://github.com');
    expect(m.title, contains('GitHub'));
  }, skip: skip, timeout: Timeout(Duration(seconds: 90)));

  test('pk_ refused without Origin (native app) and from other origins', () async {
    final native = UnfurlrClient(baseUrl: base, apiKey: pk);
    await expectLater(native.metadata('https://github.com'),
        throwsA(isA<UnfurlrException>().having((e) => e.code, 'code', 'origin_not_allowed')));
    final evil = UnfurlrClient(baseUrl: base, apiKey: pk, httpClient: _WithOrigin('https://evil.example'));
    await expectLater(evil.metadata('https://github.com'),
        throwsA(isA<UnfurlrException>().having((e) => e.statusCode, 'status', 403)));
  }, skip: skip);

  test('pk_ refused on account endpoints', () async {
    final c = UnfurlrClient(baseUrl: base, apiKey: pk, httpClient: _WithOrigin(origin));
    await expectLater(c.usage(), throwsA(isA<UnfurlrException>().having((e) => e.statusCode, 'status', 403)));
  }, skip: skip);
}
