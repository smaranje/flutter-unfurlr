import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:unfurlr_any_link_preview/unfurlr_any_link_preview.dart';

void main() {
  UnfurlrClient mock(int status, Map<String, dynamic> body) => UnfurlrClient(
        apiKey: 'pk_your_key',
        httpClient: MockClient((_) async => http.Response(jsonEncode(body), status,
            headers: {'content-type': 'application/json'})),
      );

  test('toAnyLinkMetadata maps fields', () {
    final m = toAnyLinkMetadata(UnfurlrMetadata.fromJson({
      'url': 'https://x.test', 'canonical': 'https://x.test/c', 'title': 'T',
      'description': 'D', 'site_name': 'S', 'images': ['https://x.test/i.png'],
    }));
    expect([m.title, m.desc, m.image, m.url, m.siteName],
        ['T', 'D', 'https://x.test/i.png', 'https://x.test/c', 'S']);
  });

  testWidgets('renders itemBuilder with data', (t) async {
    await t.pumpWidget(MaterialApp(home: UnfurlrLinkPreview(
      link: 'https://x.test', client: mock(200, {'url': 'https://x.test', 'title': 'Hello'}),
      placeholderWidget: const Text('loading'),
      itemBuilder: (c, m, img, _) => Text(m.title ?? ''),
    )));
    expect(find.text('loading'), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('shows errorWidget on API error', (t) async {
    await t.pumpWidget(MaterialApp(home: UnfurlrLinkPreview(
      link: 'https://x.test', client: mock(401, {'error': 'bad key'}),
      errorWidget: const Text('err'),
      itemBuilder: (c, m, img, _) => const Text('ok'),
    )));
    await t.pumpAndSettle();
    expect(find.text('err'), findsOneWidget);
  });
}
