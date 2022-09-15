import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:whatsplit/methods.dart';

class TrimmerView extends StatefulWidget {
  final File file;

  const TrimmerView(this.file, {Key? key}) : super(key: key);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  final List<String> files = [];

  void setLoading(bool status) {
    setState(() {
      _progressVisibility = status;
    });
  }

  void _loadVideo() async {
    await _trimmer.loadVideo(videoFile: widget.file);
    totalVideoSeconds = await getVideoSize(widget.file);
  }

  double totalVideoSeconds = 0;

  @override
  void initState() {
    super.initState();
    getVideoSize(widget.file);
    _loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Trimmer'),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async => await performSaveVideo(),
                  child: const Text('SAVE'),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          if (files.isNotEmpty) {
                            await Share.shareFiles(files);
                          }
                        },
                  child: const Text('SHARE'),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimEditor(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    // maxVideoLength: const Duration(seconds: 30),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> performSaveVideo() async {
    await clearStorage('whatsapp');

    double cut = toMilli(30);
    double startSec = 0;

    final indexes = generateIndexes(totalVideoSeconds ~/ cut);

    setLoading(true);

    await Future.forEach(indexes, (int element) async {
      final endSec = startSec + cut;

      await _saveVideo(startSec, endSec, '$element');

      if (cut > (startSec + endSec)) {
        cut = (startSec + endSec);
      }

      startSec += cut;
    });

    setLoading(false);
  }

  Future<String> _saveVideo(
      [double? startValue, endValue, String? name]) async {
    String _value = '';

    await _trimmer.saveTrimmedVideo(
      startValue: startValue ?? 0,
      endValue: endValue ?? 0,
      onSave: (outputPath) async {
        _value = outputPath ?? '';
        checkIfExistThenAdd(files, outputPath ?? '');
      },
      videoFileName: name,
      storageDir: StorageDir.externalStorageDirectory,
      videoFolderName: 'whatsapp',
    );

    return _value;
  }
}
