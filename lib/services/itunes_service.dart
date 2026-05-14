import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class ItunesService {
  static const String _baseUrl = 'https://itunes.apple.com/search';

  Future<List<Song>> searchSongs(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl?term=${Uri.encodeComponent(query)}&entity=song&limit=25');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) {
          // Get higher quality image by replacing 100x100bb with 600x600bb
          String albumArt = item['artworkUrl100'] ?? '';
          if (albumArt.isNotEmpty) {
            albumArt = albumArt.replaceAll('100x100bb', '600x600bb');
          }

          // iTunes tracks previewUrl might be null for some songs
          String streamUrl = item['previewUrl'] ?? '';

          return Song(
            id: item['trackId'].toString(), // iTunes uses integer trackId
            title: item['trackName'] ?? 'Unknown',
            artist: item['artistName'] ?? 'Unknown',
            albumArtUrl: albumArt.isNotEmpty 
                ? albumArt 
                : 'https://images.unsplash.com/photo-1614149162883-504ce4d13909?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60',
            audioUrl: streamUrl,
            durationSeconds: item['trackTimeMillis'] != null 
                ? (item['trackTimeMillis'] as int) ~/ 1000 
                : 30, // Default to 30 if missing
          );
        }).where((song) => song.audioUrl.isNotEmpty).toList(); // Ensure we only get playable songs
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
