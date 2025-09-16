import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController durationController = TextEditingController(text: '30');

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
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: GoogleFonts.mateSc(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff487267),
        elevation: 0,
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover),
            ),
            // color: Colors.black,
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
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Segment (sec): ',
                        style: TextStyle(
                          color: Color(0xff487267),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xff487267),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                            hintText: '30',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff487267), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff487267), width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    if (progressVisibility) {
                      return;
                    }

                    setLoading(true);

                    final parsed = int.tryParse(durationController.text);
                    final segmentSec = (parsed == null || parsed <= 0) ? 30 : parsed;

                    await splitter.saveAndShare(
                      widget.file,
                      files,
                      segmentSeconds: segmentSec,
                    );

                    setLoading(false);
                  },
                  child: Text(
                    AppStrings.shareVideo,
                    style: GoogleFonts.mateSc(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400),
                  ),
                  style: ButtonStyle(
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.white, width: 4),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xff487267),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: VideoViewer(trimmer: trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: trimmer,
                    viewerHeight: 50.0,
                    durationTextStyle: const TextStyle(
                      color: Color(0xff487267),
                    ),
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
                    size: 100.0,
                    color: const Color(0xff487267),
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
