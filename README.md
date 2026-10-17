# unfurlr (Dart)

Dart/Flutter client for [unfurlr](https://unfurlr.onrender.com): link previews (title, description, image, favicon, oEmbed) for any URL with one GET. It works on Flutter Web without CORS errors.

**Live demo and free key:** https://unfurlr.onrender.com/?ref=gh-flutter

```dart
// Flutter Web: browser-only publishable key (see below). Server-side Dart: your secret key from an env var.
final c = UnfurlrClient(apiKey: 'pk_your_key');
final m = await c.metadata('https://github.com');
print(m.title); print(m.image);
```

Free tier: 500 requests per month. Get a key at https://unfurlr.onrender.com/?ref=gh-flutter. The free server can take about 60 s to wake, so the default timeout is 60 s.

**Which key where:**
- **Flutter Web (runs in the browser):** use a **publishable `pk_` key**, never your secret `mk_` key. Lock your secret key to your site's origins (`PUT /v1/keys/origins`), then create the browser key (`POST /v1/keys/publishable`). The browser sends `Origin` automatically, the key works only from those origins and only for previews, and it has its own 100 requests/month quota, so a leak can't touch your account's 500.
- **Android / iOS / desktop:** anything shipped in an app binary can be extracted, and these apps send no `Origin`, so `pk_` keys are refused (`origin_not_allowed`). Call your own backend, which holds the secret key, and point the client at it with `baseUrl:`.
- **Server-side Dart** (CLI, backend): the secret `mk_` key from an environment variable is fine.

**any_link_preview users:** see [`unfurlr_any_link_preview/`](unfurlr_any_link_preview/), a drop-in widget that fixes the "XMLHttpRequest error" on Flutter Web.

## Tests

```bash
dart pub get && dart test   # offline tests; live tests are skipped
# Live, browser-style (publishable key + the Origin a Flutter Web page would send), against https://unfurlr.onrender.com:
UNFURLR_PUBLISHABLE_KEY=pk_your_key UNFURLR_TEST_ORIGIN=https://your-site.example dart test test/publishable_live_test.dart
# Live, server-style (secret key):
UNFURLR_BASE_URL=https://unfurlr.onrender.com UNFURLR_API_KEY=your_secret_key dart test test/live_test.dart
```

`UNFURLR_TEST_ORIGIN` must be one of the key's allowed origins. Keys are read from the environment only.


Contact: smaran+unfurlr@mail.grokbot.com · MIT
