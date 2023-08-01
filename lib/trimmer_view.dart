import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:whatsplit/methods.dart';
import 'package:whatsplit/util/colors.dart';
import 'package:whatsplit/util/util.dart';

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
        title: Text(
          'Split Video',
          style: GoogleFonts.mateSc(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 30.0),
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 60,
                            child: OutlinedButton(
                              child: Text(
                                'Save',
                                style: GoogleFonts.mateSc(
                                  color: AppColors.whiteColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                      color: Colors.white, width: 4),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                  AppColors.primaryColor,
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              onPressed: _progressVisibility
                                  ? null
                                  : () async => await performSaveVideo(),
                            ),
                          ),
                          SizedBox(
                            width: 170,
                            height: 60,
                            child: OutlinedButton(
                              child: Text(
                                'Share',
                                style: GoogleFonts.mateSc(
                                  color: AppColors.whiteColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                      color: AppColors.whiteColor, width: 4),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                   AppColors.primaryColor,
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              onPressed: _progressVisibility
                                  ? null
                                  : () async {
                                      if (files.isNotEmpty) {
                                        await Share.shareFiles(files);
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
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
                              color: AppColors.primaryColor,
                            )
                          : const Icon(
                              Icons.play_arrow,
                              size: 80.0,
                              color: AppColors.primaryColor,
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
          ],
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
