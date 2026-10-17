import 'dart:io';
import 'package:unfurlr/unfurlr.dart';

Future<void> main(List<String> args) async {
  final c = UnfurlrClient(apiKey: Platform.environment['UNFURLR_API_KEY']);
  final m = await c.metadata(args.isEmpty ? 'https://github.com' : args.first);
  print('${m.title}\n${m.description}\n${m.image}');
  c.close();
}
