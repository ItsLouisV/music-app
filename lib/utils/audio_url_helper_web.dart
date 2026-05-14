import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<String> getAudioUrlImpl(Uint8List bytes) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'audio/mpeg'),
  );

  return web.URL.createObjectURL(blob);
}