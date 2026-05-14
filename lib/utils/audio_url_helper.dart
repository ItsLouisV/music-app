import 'dart:typed_data';
import 'audio_url_helper_stub.dart'
    if (dart.library.html) 'audio_url_helper_web.dart'
    if (dart.library.io) 'audio_url_helper_mobile.dart';

class AudioUrlHelper {
  static Future<String> getAudioUrl(Uint8List bytes) => getAudioUrlImpl(bytes);
}
