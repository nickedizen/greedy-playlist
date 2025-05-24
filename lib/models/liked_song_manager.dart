import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedSongsManager {
  static const String _key = 'liked_song_ids';

  // Simpan ID lagu ke SharedPreferences
  static Future<void> likeSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedSongs = prefs.getStringList(_key) ?? [];

    if (!likedSongs.contains(songId)) {
      likedSongs.add(songId);
      await prefs.setStringList(_key, likedSongs);
    }
  }

  // Hapus ID lagu dari SharedPreferences
  static Future<void> unlikeSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedSongs = prefs.getStringList(_key) ?? [];

    likedSongs.remove(songId);
    await prefs.setStringList(_key, likedSongs);
  }

  // Ambil semua ID lagu yang disukai
  static Future<List<String>> getLikedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Cek apakah suatu lagu disukai
  static Future<bool> isLiked(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    final likedSongs = prefs.getStringList(_key) ?? [];
    return likedSongs.contains(songId);
  }
}
