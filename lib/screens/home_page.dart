// Tambahkan import yang dibutuhkan
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import 'playlist_splash_screen.dart';

class HomePage extends StatefulWidget {
  final List<Song> songs;

  const HomePage({super.key, required this.songs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController durationController = TextEditingController(text: '5');

  @override
  Widget build(BuildContext context) {
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
      ),
      backgroundColor: Color(0xff283e77),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tentukan durasi playlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      child: TextField(
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        style: TextStyle(fontSize: 100),
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.only(left: 10)
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            int duration = int.tryParse(durationController.text) ?? 1;
                            duration++;
                            durationController.text = duration.toString();
                          }, 
                          icon: Icon(
                            Icons.arrow_upward_sharp,
                            color: Colors.white,
                          )
                        ),
                        IconButton(
                          onPressed: () {
                            int duration = int.tryParse(durationController.text) ?? 1;
                            if (duration > 1) duration--;
                            durationController.text = duration.toString();
                          }, 
                          icon: Icon(
                            Icons.arrow_downward_sharp,
                            color: Colors.white,
                          )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(durationController.text);
                if (minutes != null && minutes > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistSplashScreen(
                        targetDurationMinutes: minutes,
                        allSongs: widget.songs,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Waktu tidak valid!')
                        ),
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
                    WidgetState.error & WidgetState.hovered & WidgetState.focused & WidgetState.focused: Colors.white,
                  }
                ),
                foregroundColor: MaterialStateProperty.all(Color(0xff1f2b4c)),
              ),
              child: Text('Create Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}
