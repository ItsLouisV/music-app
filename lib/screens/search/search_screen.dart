import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/itunes_service.dart';
import '../../providers/audio_provider.dart';
import '../../models/song.dart';
import '../../widgets/song_tile.dart';
import '../player/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _itunesService = ItunesService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  
  List<Song> _searchResults = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    setState(() {
      _query = query;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    
    try {
      final results = await _itunesService.searchSongs(query);
      if (mounted && _query == query) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Search',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                itemColor: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5) ?? Colors.grey,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                placeholder: 'Artists, songs, or podcasts',
                placeholderStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.4)),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: _query.trim().isEmpty
                  ? _buildCategories()
                  : _isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : _searchResults.isEmpty
                          ? Center(child: Text('No results found', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5))))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final song = _searchResults[index];
                                return SongTile(
                                  song: song,
                                  onTap: () {
                                    Provider.of<AudioProvider>(context, listen: false)
                                        .playSong(song, _searchResults);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      builder: (context) => const PlayerScreen(),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Pop',
      'color': Colors.pink,
      'image': 'https://images.unsplash.com/photo-1514525253361-bee8718a3427?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'Rock',
      'color': Colors.blue,
      'image': 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'Hip-Hop',
      'color': Colors.orange,
      'image': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'Electronic',
      'color': Colors.purple,
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'Jazz',
      'color': Colors.teal,
      'image': 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'Classical',
      'color': Colors.red,
      'image': 'https://images.unsplash.com/photo-1465847793335-da3b34f82873?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'R&B',
      'color': Colors.green,
      'image': 'https://images.unsplash.com/photo-1459749411177-042180ce673c?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
    {
      'title': 'Lofi',
      'color': Colors.indigo,
      'image': 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=60'
    },
  ];

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Browse Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () {
                  _searchController.text = category['title'];
                  _onSearchChanged(category['title']);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Background Image
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: category['image'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: category['color']),
                          errorWidget: (context, url, error) => Container(color: category['color']),
                        ),
                      ),
                      // Overlay Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category Title
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          category['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
