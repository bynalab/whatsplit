import 'dart:io';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:whatsapp_trimmer/util.dart';
import 'package:path_provider/path_provider.dart';

Future<VideoData?> getVideoInfo(File video) async {
  final _videoInfo = FlutterVideoInfo();
  final videoInfo = await _videoInfo.getVideoInfo(video.path);

  return videoInfo;
}

Future<double> getVideoSize(File file) async {
  final videoSize = await getVideoInfo(file);

  return videoSize?.duration ?? 0;
}

double toMilli(int sec) {
  return Duration(seconds: sec).inMilliseconds.toDouble();
}

List<int> generateIndexes(int length) {
  List<int> indexes = [];
  List.generate(length, (index) => indexes.add(index + 1));

  return indexes;
}

Future<String?> saveVideo([double? startValue, endValue, String? name]) async {
  final Trimmer _trimmer = Trimmer();

  String? _value;

  await _trimmer.saveTrimmedVideo(
    startValue: startValue ?? 0,
    endValue: endValue ?? 0,
    onSave: (String? outputPath) async {
      _value = outputPath;
      consolePrint(_value);
    },
    videoFileName: name,
    storageDir: StorageDir.externalStorageDirectory,
    videoFolderName: 'whatsapp',
  );

  return _value!;
}

bool checkIfExistThenAdd(List list, value) {
  if (!list.contains(value)) {
    list.add(value);
    return true;
  }
  return false;
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

Future<Directory> getDirectory() async {
  return await getApplicationDocumentsDirectory();
}

Future<Directory?> getExternalDirectory() async {
  return await getExternalStorageDirectory();
}

Future<String> getDirectoryPath() async {
  return (await getExternalDirectory())!.path;
}
