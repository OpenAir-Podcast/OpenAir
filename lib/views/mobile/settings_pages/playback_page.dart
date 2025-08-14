import 'package:flutter/material.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({super.key});

  @override
  State<PlaybackPage> createState() => PlaybackPageState();
}

class PlaybackPageState extends State<PlaybackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playback'),
      ),
      body: Center(
        child: Text('Playback settings will be implemented here.'),
      ),
    );
  }
}
