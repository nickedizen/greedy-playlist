import 'package:flutter/material.dart';
import 'package:playlist/models/liked_song_manager.dart';
import '../models/song.dart';
import 'playlist_screen.dart';
import 'dart:math';

class PlaylistSplashScreen extends StatefulWidget {
  final int targetDurationMinutes;
  final List<Song> allSongs;

  const PlaylistSplashScreen({
    super.key,
    required this.targetDurationMinutes,
    required this.allSongs,
  });

  @override
  State<PlaylistSplashScreen> createState() => _PlaylistSplashScreenState();
}

class _PlaylistSplashScreenState extends State<PlaylistSplashScreen> {
  @override
  void initState() {
    super.initState();
    _createPlaylist();
  }

  Future<Map<String, double>> calculateUserPreferenceAverage() async {
    final likedIdsRaw = await LikedSongsManager.getLikedSongs();

    if (likedIdsRaw == null || likedIdsRaw.isEmpty) {
      return {
        'bpm': 0,
        'nrgy': 0,
        'dnce': 0,
        'dB': 0,
        'live': 0,
        'val': 0,
        'acous': 0,
        'spch': 0,
        'pop': 0,
      };
    }

    final likedIds = likedIdsRaw.map((e) => int.tryParse(e)).whereType<int>().toSet();
    final likedSongs = widget.allSongs.where((song) => likedIds.contains(song.id)).toList();

    int totalBpm = 0, totalNrgy = 0, totalDnce = 0, totalDb = 0, totalLive = 0;
    int totalVal = 0, totalAcous = 0, totalSpch = 0, totalPop = 0;

    for (var song in likedSongs) {
      totalBpm += song.bpm;
      totalNrgy += song.nrgy;
      totalDnce += song.dnce;
      totalDb += song.dB;
      totalLive += song.live;
      totalVal += song.val;
      totalAcous += song.acous;
      totalSpch += song.spch;
      totalPop += song.pop;
    }

    int count = likedSongs.length;

    return {
      'bpm': totalBpm / count,
      'nrgy': totalNrgy / count,
      'dnce': totalDnce / count,
      'dB': totalDb / count,
      'live': totalLive / count,
      'val': totalVal / count,
      'acous': totalAcous / count,
      'spch': totalSpch / count,
      'pop': totalPop / count,
    };
  }

  Future<void> _createPlaylist() async {
    Map<String, double> userPreference = await calculateUserPreferenceAverage();
    debugPrint('User Preference: $userPreference');

    List<MapEntry<int, double>> songScores = [];
    for (int i = 0; i < widget.allSongs.length; i++) {
      final song = widget.allSongs[i];
      final similarity = _cosineSimilarity(song, userPreference);
      songScores.add(MapEntry(i, similarity));
      debugPrint('${song.title}, similarity: $similarity');
    }

    songScores.sort((a, b) => b.value.compareTo(a.value));

    int totalDur = 0;
    int maxDur = widget.targetDurationMinutes * 60;
    List<int> selectedIds = [];
    List<double> selectedIdsScores = [];

    for (var entry in songScores) {
      final song = widget.allSongs[entry.key];
      if (totalDur + song.dur <= maxDur) {
        selectedIds.add(entry.key);
        selectedIdsScores.add(entry.value);
        totalDur += song.dur;
      } else {
        break;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistScreen(
          selectedIds: selectedIds,
          selectedIdsScores: selectedIdsScores,
          allSongs: widget.allSongs,
        ),
      ),
    );
  }

  double _cosineSimilarity(Song song, Map<String, double> userPref) {
    final keys = ['bpm', 'nrgy', 'dnce', 'dB', 'live', 'val', 'acous', 'spch', 'pop'];
    double dot = 0, songMag = 0, prefMag = 0;

    for (var key in keys) {
      double s = _getSongValue(song, key);
      double u = userPref[key] ?? 0;
      dot += s * u;
      songMag += s * s;
      prefMag += u * u;
    }

    if (songMag == 0 || prefMag == 0) return 0;
    return dot / (sqrt(songMag) * sqrt(prefMag));
  }

  double _getSongValue(Song song, String key) {
    switch (key) {
      case 'bpm': return song.bpm.toDouble();
      case 'nrgy': return song.nrgy.toDouble();
      case 'dnce': return song.dnce.toDouble();
      case 'dB': return song.dB.toDouble();
      case 'live': return song.live.toDouble();
      case 'val': return song.val.toDouble();
      case 'acous': return song.acous.toDouble();
      case 'spch': return song.spch.toDouble();
      case 'pop': return song.pop.toDouble();
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff1f2b4c),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Membuat playlist...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
