import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/song.dart';
import '../../services/supabase_service.dart';
import '../../providers/audio_provider.dart';
import '../screens/library/add_to_playlist_modal.dart';
import 'music_visualizer.dart';

class SongTile extends StatefulWidget {
  final Song song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  final _supabaseService = SupabaseService();

  void _showOptions() async {
    final isFav = await _supabaseService.isFavorite(widget.song);
    
    if (!mounted) return;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.song.albumArtUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 64, height: 64, color: Colors.grey[800],
                ),
                errorWidget: (context, url, error) => Container(
                  width: 64, height: 64, color: Colors.grey[800],
                  child: const Icon(CupertinoIcons.music_note, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.song.title, style: const TextStyle(fontSize: 16)),
          ],
        ),
        message: Text(widget.song.artist),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              
              final messenger = ScaffoldMessenger.of(this.context);

              await _supabaseService.toggleFavorite(widget.song);
              
              if (!mounted) return;
              
              messenger.showSnackBar(
                SnackBar(
                  content: Text(isFav ? 'Đã bỏ yêu thích' : 'Đã thêm vào yêu thích'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart, 
                     color: isFav ? Theme.of(this.context).primaryColor : Theme.of(this.context).iconTheme.color),
                const SizedBox(width: 8),
                Text(isFav ? 'Bỏ yêu thích' : 'Yêu thích'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => AddToPlaylistModal(song: widget.song),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.text_badge_plus, color: Theme.of(context).iconTheme.color),
                SizedBox(width: 8),
                Text('Thêm vào Danh sách phát...'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final isCurrentSong = audioProvider.currentSong?.id == widget.song.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: widget.song.albumArtUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 56,
                height: 56,
                color: Colors.grey[800],
                child: const Icon(CupertinoIcons.music_note, color: Colors.white54),
              ),
              errorWidget: (context, url, error) => Container(
                width: 56,
                height: 56,
                color: Colors.grey[800],
                child: const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.white54),
              ),
            ),
          ),
          if (isCurrentSong)
            StreamBuilder<bool>(
              stream: audioProvider.player.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: MusicVisualizer(
                      barCount: 3,
                      color: Colors.white,
                      isAnimate: isPlaying,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      title: Text(
        widget.song.title,
        style: TextStyle(
          fontWeight: FontWeight.w600, 
          color: isCurrentSong 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).textTheme.bodyLarge?.color, 
          fontSize: 16
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.song.artist,
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(CupertinoIcons.ellipsis, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
        onPressed: _showOptions,
      ),
      onTap: widget.onTap,
    );
  }
}
