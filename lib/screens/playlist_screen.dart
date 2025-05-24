import 'package:flutter/material.dart';
import 'package:playlist/models/liked_song_manager.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/song.dart';

class PlaylistScreen extends StatefulWidget {
  final List<int> selectedIds;
  final List<double> selectedIdsScores;
  final List<Song> allSongs;

  PlaylistScreen({
    super.key,
    required this.selectedIds,
    required this.selectedIdsScores,
    required this.allSongs
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  int _currentIndex = 0;
  late Song _currentSong;
  YoutubePlayerController? _controller;
  bool _hasSongs = true;

  @override
  void initState() {
    super.initState();

    if (widget.selectedIds.isEmpty) {
      _hasSongs = false;
      return;
    }

    _currentSong = widget.allSongs[widget.selectedIds[_currentIndex]];
    _initPlayer();
    _controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _initPlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: _currentSong.vidId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        hideControls: true,
      ),
    )..addListener(_videoListener);
  }

  void _videoListener() {
    if (_controller?.value.playerState == PlayerState.ended) {
      _playNextVideo();
    }
  }

  void _playPreviousVideo() {
    if (!_hasSongs || _currentIndex <= 0) return;
    _controller?.removeListener(_videoListener);
    _currentIndex--;
    _currentSong = widget.allSongs[widget.selectedIds[_currentIndex]];
    _controller?.load(_currentSong.vidId);
    _controller?.addListener(_videoListener);
  }

  void _playNextVideo() {
    if (!_hasSongs || _currentIndex >= widget.selectedIds.length - 1) return;
    _controller?.removeListener(_videoListener);
    _currentIndex++;
    _currentSong = widget.allSongs[widget.selectedIds[_currentIndex]];
    _controller?.load(_currentSong.vidId);
    _controller?.addListener(_videoListener);
  }

  void _playSpecificVideo(int index) {
    if (!_hasSongs) return;
    _controller?.removeListener(_videoListener);
    _currentIndex = index;
    _currentSong = widget.allSongs[widget.selectedIds[_currentIndex]];
    _controller?.load(_currentSong.vidId);
    _controller?.addListener(_videoListener);
  }

  String _getTotalDuration() {
    int totalSeconds = widget.selectedIds
        .map((id) => widget.allSongs[id].dur)
        .fold(0, (prev, dur) => prev + dur);
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSongs) {
      return Scaffold(
        backgroundColor: Color(0xff283e77),
        appBar: AppBar(
          title: const Text(
            "Greedy Playlist",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff1f2b4c),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Tidak ada Lagu",
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
      );
    }
    final songs = widget.selectedIds.map((i) => widget.allSongs[i]).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Greedy Playlist",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Color(0xff1f2b4c),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentSong.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 4),
                          Text(
                            _currentSong.artist,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<bool>(
                      future: LikedSongsManager.isLiked(_currentSong.id.toString()),
                      builder: (context, snapshot) {
                        final isLiked = snapshot.data ?? false;

                        return IconButton(
                          icon: Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: Colors.black
                          ),
                          onPressed: () async {
                            if (isLiked) {
                              await LikedSongsManager.unlikeSong(_currentSong.id.toString());
                            } else {
                              await LikedSongsManager.likeSong(_currentSong.id.toString());
                            }
                            setState(() {}); // Refresh UI
                          },
                        );
                      },
                    )
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ElevatedButton(
                      onPressed: () => _playPreviousVideo(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15), // semakin besar = tombol lebih besar
                        backgroundColor: Colors.white, // warna tombol
                      ),
                      child: Icon(
                        Icons.skip_previous,
                        size: 25,
                        color: Colors.black,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        (_controller!.value.playerState == PlayerState.playing)
                            ? _controller!.pause()
                            : _controller!.play();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15), // semakin besar = tombol lebih besar
                        backgroundColor: Colors.white, // warna tombol
                      ),
                      child: Icon(
                        (_controller!.value.playerState == PlayerState.playing)
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 36,
                        color: Colors.black,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () => _playNextVideo(),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15), // semakin besar = tombol lebih besar
                        backgroundColor: Colors.white, // warna tombol
                      ),
                      child: Icon(
                        Icons.skip_next,
                        size: 25,
                        color: Colors.black,
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xff1f2b4c),
            ),
            child: Center(
              child: Text(
                'YOUR PLAYLIST  • ${_getTotalDuration()}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xff283e77),
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final density = widget.selectedIdsScores[index];
                  return Container(
                    color: _currentIndex == index ? Color(0xff6d85c2) : Colors.transparent,
                    child:
                      ListTile(
                        onTap: () => _playSpecificVideo(index),
                        leading: Icon(Icons.music_note, color: Colors.white,),
                        title: Text(
                          song.title,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${song.artist} • ${(song.dur / 60).floor()}:${(song.dur % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            density.isNaN ? '0' : (density >= 1.0 ? '100' : '${(density * 100).toStringAsFixed(1)}'),
                            style: TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

} 
