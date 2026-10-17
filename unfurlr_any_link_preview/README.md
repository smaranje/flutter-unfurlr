# unfurlr_any_link_preview

**Live demo and free key:** https://unfurlr.onrender.com/?ref=gh-flutter

**UNTESTED skeleton:** Flutter isn't installed on the build box, so this package has never been compiled or run. The `unfurlr` core package it depends on is tested.

`any_link_preview` fetches pages straight from the browser, so on Flutter Web it fails with CORS ("XMLHttpRequest error"). This package fetches through unfurlr instead and hands any_link_preview's `Metadata` to your existing `itemBuilder`.

```dart
UnfurlrLinkPreview(
  link: url,
  client: UnfurlrClient(apiKey: 'pk_your_key'), // Flutter Web: publishable pk_ key (origin-locked, own 100/mo quota)
  itemBuilder: (context, metadata, image, svg) => MyCard(metadata, image),
)
```
Or convert directly: `toAnyLinkMetadata(await client.metadata(url))`.

Never put your secret `mk_` key in a Flutter app. On **Web**, create a publishable key: set origins with `PUT /v1/keys/origins`, then `POST /v1/keys/publishable` (both called with your secret key, from your machine). On **Android/iOS/desktop**, there's no `Origin` header and anything in the binary can be extracted, so proxy through your backend instead: `UnfurlrClient(baseUrl: 'https://your-backend.example/unfurlr')`.
