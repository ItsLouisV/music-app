class Song {
  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;
  final String audioUrl;
  final int durationSeconds;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.audioUrl,
    this.durationSeconds = 0,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] ?? 'Unknown Artist',
      albumArtUrl: json['image_url'] ?? json['cover_url'] ?? '',
      audioUrl: json['stream_url'] ?? json['file_url'] ?? '',
      durationSeconds: json['duration_seconds'] ?? json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'image_url': albumArtUrl,
      'stream_url': audioUrl,
      'duration_seconds': durationSeconds,
    };
  }
}
