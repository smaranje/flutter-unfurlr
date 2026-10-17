/// Adapter between the unfurlr API and the any_link_preview package.
library;

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/widgets.dart';
import 'package:unfurlr/unfurlr.dart';

export 'package:unfurlr/unfurlr.dart';

/// Convert unfurlr metadata into any_link_preview's [Metadata].
Metadata toAnyLinkMetadata(UnfurlrMetadata m) => Metadata()
  ..title = m.title
  ..desc = m.description
  ..image = m.image
  ..url = m.canonical ?? m.url
  ..siteName = m.siteName;

/// Fetch via unfurlr (no CORS issues on Web) and render with any_link_preview's
/// builder signature, so existing `itemBuilder`s can be reused unchanged.
class UnfurlrLinkPreview extends StatefulWidget {
  final String link;
  final UnfurlrClient client;
  final Widget Function(BuildContext, Metadata, ImageProvider?, Widget?) itemBuilder;
  final Widget? placeholderWidget;
  final Widget? errorWidget;

  const UnfurlrLinkPreview({
    super.key,
    required this.link,
    required this.client,
    required this.itemBuilder,
    this.placeholderWidget,
    this.errorWidget,
  });

  @override
  State<UnfurlrLinkPreview> createState() => _UnfurlrLinkPreviewState();
}

class _UnfurlrLinkPreviewState extends State<UnfurlrLinkPreview> {
  late Future<UnfurlrMetadata> _f;

  @override
  void initState() {
    super.initState();
    _f = widget.client.metadata(widget.link);
  }

  @override
  void didUpdateWidget(UnfurlrLinkPreview old) {
    super.didUpdateWidget(old);
    if (old.link != widget.link) _f = widget.client.metadata(widget.link);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<UnfurlrMetadata>(
        future: _f,
        builder: (context, s) {
          if (s.hasError) return widget.errorWidget ?? const SizedBox.shrink();
          if (!s.hasData) return widget.placeholderWidget ?? const SizedBox.shrink();
          final md = toAnyLinkMetadata(s.data!);
          final img = md.image == null ? null : NetworkImage(md.image!);
          return widget.itemBuilder(context, md, img, null);
        },
      );
}
