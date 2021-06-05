import 'dart:async';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'music.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:audioplayer/audioplayer.dart';

void main() => {
  runApp(new MyApp())
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Music Prelude',
      theme: new ThemeData(
        // primaryColor: Colors.blueGrey[800] ,
        primarySwatch: Colors.blueGrey,
        // scaffoldBackgroundColor: Colors.blueGrey[600],
        fontFamily: 'Sylfaen'
      ),
      debugShowCheckedModeBanner: false,
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }
}

class _Home extends State<Home> {

  List<Music> myMusicList = [
    // new Music('BattleCry', 'Nujabes', 'assets/images/battlecry.png', 'assets/audio/nujabes-battlecry.mp3'),
    // new Music('The Stroll', 'Nujabes', 'assets/images/the-stroll.png', 'assets/audio/nujabes-the-stroll-samurai-champloo.mp3')
    new Music('BattleCry', 'Nujabes', 'assets/images/battlecry.png', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Music('The Stroll', 'Nujabes', 'assets/images/the-stroll.png', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription stateSubscription;
  Music actualMusic;
  Duration position = new Duration(seconds: 0);
  Duration period = new Duration(seconds: 10);
  PlayerState status = PlayerState.stopped;
  int index = 0;

  void initState() {
    super.initState();
    actualMusic = myMusicList[index];
    audioPlayerConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Music Prelude'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[800],
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(actualMusic.imagePath)
              ),
            ),
            textWithStyle(actualMusic.title, 1.5),
            textWithStyle(actualMusic.artist, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                specialButton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                specialButton(
                    (status == PlayerState.playing) ? Icons.pause : Icons.play_arrow,
                    45.0,
                    (status == PlayerState.playing) ? ActionMusic.stop : ActionMusic.play
                ),
                specialButton(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textWithStyle(fromDuration(position), 0.8),
                textWithStyle(fromDuration(period), 0.8),
              ],
            ),
            new Slider(
              value: position.inSeconds.toDouble(),
              min: 0.0,
              max: 30.0,
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d) {
                setState(() {
                  audioPlayer.seek(d);
                  // Duration newDuration = new Duration(seconds: d.toInt());
                  // position = newDuration;
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Text textWithStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontStyle: FontStyle.italic
      ),
    );
  }

  IconButton specialButton(IconData icon, double size, ActionMusic action) {
    return new IconButton(
        iconSize: size,
        color: Colors.white,
        icon: new Icon(icon),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              print(('Play'));
              play();
              break;
            case ActionMusic.stop:
              print(('Stop'));
              stop();
              break;
            case ActionMusic.forward:
              print(('Forward'));
              forward();
              break;
            case ActionMusic.rewind:
              print(('Rewind'));
              rewind();
              break;
          }
        }
    );
  }

  void audioPlayerConfiguration() {
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged.listen(
            (pos) {
              setState(() {
                position = pos;
              });
            }
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen(
          (state) {
            if (state == AudioPlayerState.PLAYING) {
              setState(() {
                period = audioPlayer.duration;
              });
            } else if (state == AudioPlayerState.STOPPED) {
              setState(() {
                status = PlayerState.stopped;
              });
            }
          }, onError: (message) {
            print('Error : $message');
            setState(() {
              status = PlayerState.stopped;
              period = new Duration(seconds: 0);
              position = new Duration(seconds: 0);
            });
          }
    );
  }

  Future play() async {
    await audioPlayer.play(actualMusic.urlSong);
    setState(() {
      status = PlayerState.playing;
    });
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      status = PlayerState.paused;
    });
  }

  void forward() {
    if (index == myMusicList.length  - 1){
      index = 0;
    } else {
      index++;
    }
    actualMusic = myMusicList[index];
    audioPlayer.stop();
    audioPlayerConfiguration();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = myMusicList.length - 1;
      } else {
        index--;
      }
      actualMusic = myMusicList[index];
      audioPlayer.stop();
      audioPlayerConfiguration();
      play();
    }
  }

  String fromDuration(Duration period) {
    print(period);
    return period.toString().split('.').first;
  }
}

enum ActionMusic {
  play,
  stop,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused
}