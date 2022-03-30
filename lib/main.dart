import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Demo(),
    );
  }
}
class Demo extends StatefulWidget {
  Demo({Key? key}) : super(key: key);

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';
  bool recording = false;

  final FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  final FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openRecorder();

    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        return;
      }
    }
  }

  void gugu() async{
    Directory? ss = await getExternalStorageDirectory();
    if (ss != null) {
      _mPath= ss.path+"/dada.mp4";
      print(ss.path);
    }
  }

  @override
  void initState() {
    gugu();
    _mPlayer!.openPlayer().then((value) {});

    // await openTheRecorder().then((value) {});
    // TODO: implement initState

    openTheRecorder().then((value) {
      setState(() {});
    });
    super.initState();
  }

  void play() {
    _mPlayer!
        .startPlayer(
        fromURI: _mPath,
        // 'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3',
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void record() async {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: AudioSource.microphone,
    )
        .then((value) {});

    setState(() {
      recording = true;
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        recording = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_sound demo'),
      ),
      body: Row(
        children: [
          const SizedBox(
            width: 3,
          ),
          ElevatedButton(
              onPressed: () {
                play();
              },
              child: Text('Play')),
          const SizedBox(
            width: 20,
          ),
          // 一般播放和录音没啥关系
          ElevatedButton(
              onPressed: () {
                if (recording) {
                  stopRecorder();
                } else {
                  record();
                }
              },
              child: Text(recording ? 'Stop' : 'Record'))
        ],
      ),
    );
  }
}