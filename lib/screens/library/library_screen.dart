// ignore_for_file: experimental_member_use

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../services/supabase_service.dart';
import '../../utils/audio_url_helper.dart';
import 'playlist_detail_screen.dart';

class MyByteSource extends StreamAudioSource {
  final Uint8List _buffer;
  MyByteSource(this._buffer);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.length;
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isUploading = false;
  late final Stream<List<Map<String, dynamic>>> _playlistsStream;
  late final Stream<List<Map<String, dynamic>>> _favoritesStream;

  @override
  void initState() {
    super.initState();
    _playlistsStream = _supabaseService.getPlaylistsStream();
    _favoritesStream = _supabaseService.getFavoritesStream();
  }

  Future<void> _uploadSong() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return;

        final titleController = TextEditingController(text: file.name.split('.').first);
        final artistController = TextEditingController(text: 'Louis Artist');
        Uint8List? selectedImageBytes;
        String? selectedImageExtension;

        if (!mounted) return;

        final bool? confirm = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => CupertinoAlertDialog(
              title: const Text('Song Details'),
              content: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final imgResult = await FilePicker.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (imgResult != null && imgResult.files.isNotEmpty) {
                          setDialogState(() {
                            selectedImageBytes = imgResult.files.first.bytes;
                            selectedImageExtension = imgResult.files.first.extension;
                          });
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          image: selectedImageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(selectedImageBytes!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImageBytes == null
                            ? const Icon(CupertinoIcons.camera, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to add cover photo', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: titleController,
                      placeholder: 'Title',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: artistController,
                      placeholder: 'Artist',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Upload'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        );

        if (confirm != true) return;

        setState(() => _isUploading = true);

        int durationSeconds = 0;
        try {
          final player = AudioPlayer();
          final audioUrl = await AudioUrlHelper.getAudioUrl(file.bytes!);
          final dur = await player.setUrl(audioUrl);
          durationSeconds = dur?.inSeconds ?? 0;
          await player.dispose();
        } catch (e) {
          debugPrint('Could not extract duration locally: $e');
        }

        await _supabaseService.uploadSong(
          title: titleController.text.trim(),
          artist: artistController.text.trim(),
          fileBytes: file.bytes!,
          extension: file.extension ?? 'mp3',
          durationSeconds: durationSeconds,
          imageBytes: selectedImageBytes,
          imageExtension: selectedImageExtension,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload successful!')),
          );
        }
        debugPrint('Upload successful!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
        debugPrint('Upload failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _createNewPlaylist() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Tạo danh sách phát mới'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Tên danh sách phát',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                await _supabaseService.createPlaylist(name);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: icon,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 14)),
      trailing: Icon(CupertinoIcons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.2), size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              heroTag: 'library_nav_bar',
              largeTitle: const Text('Your Library'),
              backgroundColor: Colors.transparent,
              border: null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(CupertinoIcons.plus, color: Theme.of(context).iconTheme.color),
                    onPressed: _createNewPlaylist,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: CupertinoButton(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _isUploading ? null : _uploadSong,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isUploading 
                          ? const CupertinoActivityIndicator(color: Colors.white) 
                          : const Icon(CupertinoIcons.cloud_upload, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _isUploading ? 'Uploading...' : 'Upload MP3', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: Divider(color: Theme.of(context).dividerColor)),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _favoritesStream,
              builder: (context, favoritesSnapshot) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _playlistsStream,
                  builder: (context, playlistsSnapshot) {
                    if (favoritesSnapshot.connectionState == ConnectionState.waiting || 
                        playlistsSnapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(child: CupertinoActivityIndicator()),
                      );
                    }

                    final playlists = playlistsSnapshot.data ?? [];
                    final favoriteCount = favoritesSnapshot.data?.length ?? 0;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            // Liked Songs
                            return _buildPlaylistItem(
                              context: context,
                              title: 'Liked Songs',
                              subtitle: '$favoriteCount songs',
                              icon: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(CupertinoIcons.heart_fill, color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PlaylistDetailScreen(isFavorites: true),
                                  ),
                                );
                              },
                            );
                          }
                          
                          // User Playlists
                          final playlist = playlists[index - 1];
                          return _buildPlaylistItem(
                            context: context,
                            title: playlist['name'],
                            subtitle: 'Playlist',
                            icon: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(CupertinoIcons.music_note_list, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5)),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDetailScreen(playlist: playlist),
                                ),
                              );
                            },
                          );
                        },
                        childCount: playlists.length + 1, // +1 for Liked Songs
                      ),
                    );
                  }
                );
              }
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)), // Bottom padding
          ],
        ),
      ),
    );
  }
}

