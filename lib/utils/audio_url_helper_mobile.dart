import 'dart:convert';
import 'dart:typed_data';

Future<String> getAudioUrlImpl(Uint8List bytes) async {
  // Mobile supports data URIs well enough for duration extraction
  return 'data:audio/mpeg;base64,${base64Encode(bytes)}';
}
