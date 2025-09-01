import 'dart:io';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:whatsplit/util.dart';
import 'package:path_provider/path_provider.dart';

class Splitter {
  final Trimmer trimmer;

  Splitter(this.trimmer);

  final folder = 'splitter';

  Future<VideoData?> getVideoInfo(XFile video) async {
    final _videoInfo = FlutterVideoInfo();
    final videoInfo = await _videoInfo.getVideoInfo(video.path);

    return videoInfo;
  }

  Future<double> getVideoDuration(XFile video) async {
    final videoInfo = await getVideoInfo(video);

    return videoInfo?.duration ?? 0;
  }

  double toMilliseconds(int sec) {
    return Duration(seconds: sec).inMilliseconds.toDouble();
  }

  Future<void> saveAndShare(XFile file, List<XFile> files) async {
    await clearStorage(folder);
    files.clear();

    final totalVideoSeconds = await getVideoDuration(file);
    final cut = toMilliseconds(30);

    for (double i = 0; i < totalVideoSeconds; i += cut) {
      final startValue = i;
      final endValue = i + cut;

      await trimmer.saveTrimmedVideo(
        startValue: startValue,
        endValue: endValue,
        videoFileName: i.toString(),
        onSave: (outputPath) {
          if (outputPath != null) {
            checkIfExistThenAdd(files, XFile(outputPath));
          }
        },
        storageDir: StorageDir.externalStorageDirectory,
        videoFolderName: folder,
      );
    }

    await Future.delayed(const Duration(seconds: 1));

    if (files.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(
          files: files,
          text: 'Check out this video',
        ),
      );
    }
  }

  void checkIfExistThenAdd(List<dynamic> files, dynamic file) {
    if (!files.contains(file)) {
      files.add(file);
    }
  }

  Future<void> clearStorage(String folder) async {
    try {
      final path = await getDirectoryPath();
      final dir = Directory(path + '/' + folder);
      dir.deleteSync(recursive: true);
    } catch (e) {
      consolePrint(e);
    }
  }

  Future<String> getDirectoryPath() async {
    return (await getExternalStorageDirectory())!.path;
  }
}
