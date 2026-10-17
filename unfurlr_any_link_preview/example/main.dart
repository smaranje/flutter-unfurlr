import 'package:flutter/material.dart';
import 'package:unfurlr_any_link_preview/unfurlr_any_link_preview.dart';

// Flutter Web: pass a publishable key at build time (never the secret mk_ key, which would end up in the bundle):
//   flutter run -d chrome --dart-define=UNFURLR_PUBLISHABLE_KEY=pk_your_key
// Mobile/desktop: point baseUrl at your own backend proxy instead.
final client = UnfurlrClient(apiKey: const String.fromEnvironment('UNFURLR_PUBLISHABLE_KEY'));

void main() => runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: UnfurlrLinkPreview(
            link: 'https://github.com',
            client: client,
            placeholderWidget: const CircularProgressIndicator(),
            itemBuilder: (context, m, image, _) => Card(
              child: ListTile(
                leading: image == null ? null : Image(image: image, width: 64),
                title: Text(m.title ?? m.url ?? ''),
                subtitle: Text(m.desc ?? ''),
              ),
            ),
          ),
        ),
      ),
    ));
