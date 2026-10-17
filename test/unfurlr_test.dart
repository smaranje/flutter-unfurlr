import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:unfurlr/unfurlr.dart';

const meta = {
  'url': 'https://github.com/', 'title': 'GitHub', 'description': 'd', 'site_name': 'GitHub',
  'canonical': 'https://github.com', 'favicon': 'https://github.com/f.png',
  'images': ['https://x/og.png'], 'oembed': null,
};

void main() {
  test('metadata sends key and parses', () async {
    late http.Request seen;
    final c = UnfurlrClient(apiKey: 'k1', httpClient: MockClient((r) async {
      seen = r;
      return http.Response(jsonEncode(meta), 200);
    }));
    final m = await c.metadata('https://github.com');
    expect(seen.url.toString(), 'https://unfurlr.onrender.com/v1/metadata?url=https%3A%2F%2Fgithub.com');
    expect(seen.headers['X-API-Key'], 'k1');
    expect(m.title, 'GitHub');
    expect(m.image, 'https://x/og.png');
    expect(m.siteName, 'GitHub');
  });

  test('fresh flag and trailing slash base', () async {
    final c = UnfurlrClient(baseUrl: 'http://h/', httpClient: MockClient((r) async {
      expect(r.url.toString(), 'http://h/v1/metadata?url=a&fresh=true');
      return http.Response(jsonEncode(meta), 200);
    }));
    await c.metadata('a', fresh: true);
  });

  test('error maps to UnfurlrException', () async {
    final c = UnfurlrClient(httpClient: MockClient((r) async =>
        http.Response(jsonEncode({'error': {'code': 'rate_limited', 'message': 'slow down'}}), 429)));
    await expectLater(c.metadata('x'), throwsA(isA<UnfurlrException>()
        .having((e) => e.statusCode, 'status', 429).having((e) => e.code, 'code', 'rate_limited')));
  });

  test('FastAPI detail string error', () async {
    final c = UnfurlrClient(httpClient: MockClient((r) async => http.Response(jsonEncode({'detail': 'Invalid API key'}), 401)));
    await expectLater(c.metadata('x'), throwsA(isA<UnfurlrException>().having((e) => e.message, 'msg', 'Invalid API key')));
  });

  test('missing fields tolerated', () {
    final m = UnfurlrMetadata.fromJson({'url': 'u', 'images': [1, 'a']});
    expect(m.images, ['a']);
    expect(m.title, isNull);
  });
}
