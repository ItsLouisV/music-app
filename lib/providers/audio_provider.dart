import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = -1;

  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  List<Song> get effectivePlaylist {
    final sequence = _audioPlayer.sequence;
    final shuffleIndices = _audioPlayer.shuffleIndices;
    if (!_audioPlayer.shuffleModeEnabled) {
      return sequence.map((s) => s.tag as Song).toList();
    }
    return shuffleIndices.map((i) => sequence[i].tag as Song).toList();
  }

  // Used to cancel stale playSong calls (race condition fix)
  int _playCallId = 0;

  AudioPlayer get player => _audioPlayer;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  AudioProvider() {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        notifyListeners();
      }
    });
  }

  Future<void> playSong(Song song, List<Song> playlist) async {
    // Nếu bài chọn trùng với bài đang phát, chỉ cần tiếp tục phát (nếu đang pause)
    if (currentSong?.id == song.id) {
      if (!_audioPlayer.playing) {
        _audioPlayer.play();
      }
      return;
    }

    // Tăng ID để mọi lần gọi cũ hơn biết mình đã bị cancel
    final callId = ++_playCallId;

    // Lọc bỏ các bài hát bị lỗi link (link rỗng)
    final filteredPlaylist =
        playlist.where((s) => s.audioUrl.isNotEmpty).toList();
    final targetIndex = filteredPlaylist.indexWhere((s) => s.id == song.id);

    if (targetIndex == -1) {
      debugPrint('Error: Song not found in playlist or audioUrl is empty');
      return;
    }

    // Cập nhật state ngay để UI phản hồi tức thì
    _playlist = filteredPlaylist;
    _currentIndex = targetIndex;
    notifyListeners();

    final audioSources = filteredPlaylist
        .map((s) => AudioSource.uri(Uri.parse(s.audioUrl), tag: s))
        .toList();

    // ignore: deprecated_member_use
    final audioSource = ConcatenatingAudioSource(children: audioSources);

    try {
      await _audioPlayer.stop();

      // Kiểm tra xem có lần gọi mới hơn không — nếu có thì bỏ qua
      if (callId != _playCallId) return;

      await _audioPlayer.setAudioSource(audioSource,
          initialIndex: targetIndex, initialPosition: Duration.zero);

      if (callId != _playCallId) return;

      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  Future<void> playNext() async {
    if (hasNext) {
      await _audioPlayer.seekToNext();
    }
  }

  Future<void> playPrevious() async {
    if (hasPrevious) {
      await _audioPlayer.seekToPrevious();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> toggleShuffle() async {
    final isEnabled = _audioPlayer.shuffleModeEnabled;
    if (!isEnabled) {
      await _audioPlayer.shuffle();
    }
    await _audioPlayer.setShuffleModeEnabled(!isEnabled);
  }

  Future<void> toggleRepeat() async {
    final currentMode = _audioPlayer.loopMode;
    if (currentMode == LoopMode.off) {
      await _audioPlayer.setLoopMode(LoopMode.all);
    } else if (currentMode == LoopMode.all) {
      await _audioPlayer.setLoopMode(LoopMode.one);
    } else {
      await _audioPlayer.setLoopMode(LoopMode.off);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
