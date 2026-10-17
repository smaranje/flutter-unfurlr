/// Link metadata returned by `GET /v1/metadata`.
class UnfurlrMetadata {
  final String url;
  final String? title;
  final String? description;
  final String? siteName;
  final String? canonical;
  final String? language;
  final String? favicon;
  final List<String> images;
  final Map<String, dynamic>? oembed;
  final Map<String, dynamic> raw;

  const UnfurlrMetadata({
    required this.url,
    this.title,
    this.description,
    this.siteName,
    this.canonical,
    this.language,
    this.favicon,
    this.images = const [],
    this.oembed,
    this.raw = const {},
  });

  /// First image, or null.
  String? get image => images.isEmpty ? null : images.first;

  factory UnfurlrMetadata.fromJson(Map<String, dynamic> j) => UnfurlrMetadata(
        url: (j['url'] as String?) ?? '',
        title: j['title'] as String?,
        description: j['description'] as String?,
        siteName: j['site_name'] as String?,
        canonical: j['canonical'] as String?,
        language: j['language'] as String?,
        favicon: j['favicon'] as String?,
        images: [
          for (final i in (j['images'] as List? ?? const []))
            if (i is String) i
        ],
        oembed: j['oembed'] is Map ? Map<String, dynamic>.from(j['oembed']) : null,
        raw: j,
      );
}

/// Usage for the current key (`GET /v1/usage`).
class UnfurlrUsage {
  final String tier;
  final int used;
  final int limit;
  final int remaining;
  const UnfurlrUsage({required this.tier, required this.used, required this.limit, required this.remaining});
  factory UnfurlrUsage.fromJson(Map<String, dynamic> j) => UnfurlrUsage(
        tier: '${j['tier']}',
        used: (j['used'] as num?)?.toInt() ?? 0,
        limit: (j['limit'] as num?)?.toInt() ?? 0,
        remaining: (j['remaining'] as num?)?.toInt() ?? 0,
      );
}

/// Thrown for non-2xx responses. [code] is unfurlr's error code when present.
class UnfurlrException implements Exception {
  final int statusCode;
  final String? code;
  final String message;
  const UnfurlrException(this.statusCode, this.message, {this.code});
  @override
  String toString() => 'UnfurlrException($statusCode${code == null ? '' : ', $code'}): $message';
}
