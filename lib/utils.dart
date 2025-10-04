import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'models.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<String?> pickFolder() async {
  return await FilePicker.platform.getDirectoryPath();
}

Future<List<VideoModel>> fetchAllVideos(String folderPath) async {
  final dir = Directory(folderPath);
  final files = dir.listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.mp4'))
      .toList();

  files.sort((a, b) => a.path.compareTo(b.path));

  return files.map((f) => VideoModel(id: uuid.v4(), path: f.path)).toList();
}


Future<String?> getVideoThumbnail(String videoPath) async {
  try {
    final videoFile = File(videoPath);
    if (!videoFile.existsSync()) {
      print('Video file does not exist: $videoPath');
      return null;
    }

    final thumbPath = '${Directory.systemTemp.path}\\thumb_${uuid.v4()}.png';

    final ffmpegPath = r'C:\Users\pbana\Downloads\ffmpeg-master-latest-win64-gpl-shared\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe'; // Update this



    final result = await Process.run(ffmpegPath, [
      '-i',
      videoPath,
      '-ss',
      '00:00:01.000',
      '-vframes',
      '1',
      thumbPath
    ]);
    if (result.exitCode == 0 && File(thumbPath).existsSync()) {
      return thumbPath;
    } else {
      return null;
    }
  } catch (e) {

    return null;
  }
}
