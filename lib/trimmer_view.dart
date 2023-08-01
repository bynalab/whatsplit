import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:whatsplit/app_strings.dart';
import 'package:whatsplit/splitter.dart';

class TrimmerView extends StatefulWidget {
  final XFile file;

  const TrimmerView(this.file, {Key? key}) : super(key: key);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  late Splitter splitter;
  final trimmer = Trimmer();

  double startValue = 0.0;
  double endValue = 0.0;

  bool isPlaying = false;
  bool progressVisibility = false;
  final List<XFile> files = [];

  void setLoading(bool status) {
    setState(() => progressVisibility = status);
  }

  void loadVideo() async {
    await trimmer.loadVideo(videoFile: File(widget.file.path));

    splitter = Splitter(trimmer);
  }

  @override
  void initState() {
    super.initState();

    loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
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
                  visible: progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (progressVisibility) {
                      return;
                    }

                    setLoading(true);

                    await splitter.saveAndShare(widget.file, files);

                    setLoading(false);
                  },
                  child: const Text(AppStrings.shareVideo),
                ),
                Expanded(
                  child: VideoViewer(trimmer: trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    onChangeStart: (value) => startValue = value,
                    onChangeEnd: (value) => endValue = value,
                    onChangePlaybackState: (value) {
                      setState(() => isPlaying = value);
                    },
                  ),
                ),
                TextButton(
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 80.0,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    bool playbackState = await trimmer.videoPlaybackControl(
                      startValue: startValue,
                      endValue: endValue,
                    );

                    setState(() => isPlaying = playbackState);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
