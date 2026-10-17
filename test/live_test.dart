// Live test; skipped unless UNFURLR_BASE_URL and UNFURLR_API_KEY are set.
import 'dart:io';
import 'package:test/test.dart';
import 'package:unfurlr/unfurlr.dart';

void main() {
  final base = Platform.environment['UNFURLR_BASE_URL'];
  final key = Platform.environment['UNFURLR_API_KEY'];
  final skip = (base == null || key == null) ? 'set UNFURLR_BASE_URL and UNFURLR_API_KEY' : null;
  final target = Platform.environment['UNFURLR_TEST_URL'] ?? 'https://github.com';

  test('real metadata', () async {
    final c = UnfurlrClient(baseUrl: base!, apiKey: key);
    final m = await c.metadata(target);
    expect(m.title, isNotEmpty);
    expect(m.siteName, isNotNull);
    final u = await c.usage();
    expect(u.used, greaterThan(0));
    c.close();
  }, skip: skip, timeout: Timeout(Duration(seconds: 90)));

  test('bad key rejected', () async {
    final c = UnfurlrClient(baseUrl: base!, apiKey: 'mk_invalid');
    await expectLater(c.metadata(target), throwsA(isA<UnfurlrException>().having((e) => e.statusCode, 's', 401)));
  }, skip: skip);
}
